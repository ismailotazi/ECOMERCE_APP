import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/models/order_item_model.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/order_service.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:ecomerce_app/user_dashboard/bank_transfer_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

enum PaymentMethod { cashOnDelivery, bankTransfer }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.total, required this.items});

  final double total;
  final List<Map<String, dynamic>> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final countryController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  String? savedPhone;
  String? completePhoneNumber;
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  String? paymentProofUrl;
  bool loading = false;

  String? paymentBankId;
  String? paymentBankName;

  Future<void> _loadUserInformation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists || !mounted) return;

    final data = doc.data();

    if (data == null) return;

    final firstName = data["firstName"]?.toString().trim() ?? "";
    final lastName = data["lastName"]?.toString().trim() ?? "";

    final fullName = [
      firstName,
      lastName,
    ].where((value) => value.isNotEmpty).join(" ");

    savedPhone = data["phone"]?.toString().trim();

    setState(() {
      nameController.text = fullName;

      countryController.text = data["country"]?.toString() ?? "";
      cityController.text = data["city"]?.toString() ?? "";
      addressController.text = data["address"]?.toString() ?? "";
    });
  }

  // place order function
  Future<void> _placeOrder() async {
    final t = AppLocalizations.of(context)!;

    completePhoneNumber ??= savedPhone;

    // Phone validation
    if (completePhoneNumber == null || completePhoneNumber!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.pleaseEnterYourPhoneNumber)));
      return;
    }

    // Form validation
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      // Bank Transfer
      if (_paymentMethod == PaymentMethod.bankTransfer) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BankTransferScreen()),
        );

        if (result == null || result["confirmed"] != true) {
          if (mounted) {
            setState(() => loading = false);
          }
          return;
        }

        paymentProofUrl = result["proofUrl"];
        paymentBankId = result["bankId"];
        paymentBankName = result["bankName"];
      }

      final orderItems = widget.items.map((e) {
        final List images = e["images"] is List ? e["images"] : [];

        final String image = images.isNotEmpty
            ? images.first?.toString().trim() ?? ""
            : e["image"]?.toString().trim() ?? "";

        return OrderItemModel(
          productId: e["id"]?.toString() ?? "",
          name: e["name"]?.toString() ?? "",
          image: image,
          price: (e["price"] as num?)?.toDouble() ?? 0.0,
          quantity: (e["quantity"] as num?)?.toInt() ?? 1,
        );
      }).toList();

      await OrderService().createOrder(
        userId: user.uid,
        userName: nameController.text.trim(),
        email: user.email ?? "",
        phone: completePhoneNumber ?? savedPhone ?? "",
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        country: countryController.text.trim(),
        items: orderItems,
        totalPrice: widget.total,
        paymentMethod: _paymentMethod == PaymentMethod.cashOnDelivery
            ? "Cash on Delivery"
            : "Bank Transfer",
        paymentProofUrl: paymentProofUrl,
        paymentBankId: paymentBankId,
        paymentBankName: paymentBankName,
      );

      // Remove ONLY purchased products from cart
      final selectedIds = widget.items
          .map((item) => item["id"].toString())
          .toSet();

      cartItems.removeWhere(
        (item) => selectedIds.contains(item["id"].toString()),
      );

      await CartStorage.saveCart(cartItems);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            "Order placed successfully 🎉",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } on StockException catch (e) {
      if (!mounted) return;

      final message = e.availableStock <= 0
          ? t.productOutOfStock
          : t.onlyItemsAvailable(e.availableStock);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${e.productName}: $message')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadUserInformation();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.checkout),
        leading: const CustomBackButton(),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.deliveryInformation,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 80,
                  decoration: inputDecoration(
                    context: context,
                    label: t.fullName,
                    icon: Icons.person,
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? "";

                    if (name.isEmpty) {
                      return t.pleaseEnterYourFullName;
                    }

                    if (name.length < 3) {
                      return t.pleaseEnterYourFullName;
                    }

                    if (name.length > 80) {
                      return t.nameTooLong;
                    }

                    // Must contain letters.
                    if (!RegExp(
                      r'[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
                    ).hasMatch(name)) {
                      return t.pleaseEnterAValidName;
                    }

                    // Allow letters, spaces, apostrophes and hyphens.
                    if (!RegExp(
                      r"^[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                    ).hasMatch(name)) {
                      return t.pleaseEnterAValidName;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  key: ValueKey(savedPhone),
                  initialValue: savedPhone,
                  keyboardType: TextInputType.phone,

                  decoration: inputDecoration(
                    context: context,
                    label: t.phoneNumber,
                    icon: Icons.phone,
                  ),

                  onChanged: (phone) {
                    completePhoneNumber = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: countryController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 60,
                  decoration: inputDecoration(
                    context: context,
                    label: t.country,
                    icon: Icons.public,
                  ),
                  validator: (value) {
                    final country = value?.trim() ?? "";

                    if (country.isEmpty) {
                      return t.pleaseEnterYourCountry;
                    }

                    if (country.length < 2) {
                      return t.pleaseEnterAValidCountry;
                    }

                    if (country.length > 60) {
                      return t.countryNameTooLong;
                    }

                    // Country name should contain letters.
                    if (!RegExp(
                      r'[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
                    ).hasMatch(country)) {
                      return t.pleaseEnterAValidCountry;
                    }

                    // No numbers or unusual symbols.
                    if (!RegExp(
                      r"^[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                    ).hasMatch(country)) {
                      return t.pleaseEnterAValidCountry;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: cityController,
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 60,
                  decoration: inputDecoration(
                    context: context,
                    label: t.city,
                    icon: Icons.location_city,
                  ),
                  validator: (value) {
                    final city = value?.trim() ?? "";
                    if (city.isEmpty) {
                      return t.pleaseEnterYourCity;
                    }

                    if (city.length < 2) {
                      return t.pleaseEnterAValidCity;
                    }

                    if (city.length > 60) {
                      return t.cityNameTooLong;
                    }

                    // City name should contain letters.
                    if (!RegExp(
                      r'[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
                    ).hasMatch(city)) {
                      return t.pleaseEnterAValidCity;
                    }

                    // No numbers or unusual symbols.
                    if (!RegExp(
                      r"^[A-Za-zÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                    ).hasMatch(city)) {
                      return t.pleaseEnterAValidCity;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: addressController,
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 150,
                  decoration: inputDecoration(
                    context: context,
                    label: t.address,
                    icon: Icons.location_on,
                  ),
                  validator: (value) {
                    final address = value?.trim() ?? "";
                    if (address.trim().isEmpty) {
                      return t.pleaseEnterYourAddress;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Text(
                  t.paymentMethods,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: RadioGroup<PaymentMethod>(
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                    child: Column(
                      children: [
                        RadioListTile<PaymentMethod>(
                          value: PaymentMethod.cashOnDelivery,
                          activeColor: colorScheme.primary,
                          title: Text(
                            t.cashOnDelivery,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            t.payWhenYourOrderArrives,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),

                        Divider(height: 1, color: colorScheme.outlineVariant),

                        RadioListTile<PaymentMethod>(
                          value: PaymentMethod.bankTransfer,
                          activeColor: colorScheme.primary,
                          title: Text(
                            t.bankTransfer,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            t.transferBeforeShipping,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              t.orderSummary,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.items,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              "${widget.items.length}",
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.payment,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Flexible(
                              child: Text(
                                _paymentMethod == PaymentMethod.cashOnDelivery
                                    ? t.cashOnDelivery
                                    : t.bankTransfer,
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        Divider(height: 30, color: colorScheme.outlineVariant),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.total,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$${widget.total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            t.placeOrder,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
