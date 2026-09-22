import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_firestore.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/checkout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final bool showArrowBack;

  const CartPage({super.key, this.showArrowBack = true});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, int> quantities = {};
  final Set<String> selectedProductIds = {};
  StreamSubscription<List<Map<String, dynamic>>>? _cartSubscription;
  bool _isLoadingCart = true;
  void _listenToCart() {
    _cartSubscription?.cancel();

    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    _cartSubscription = CartFirestore.cartStream().listen((firebaseCart) {
      if (!mounted) return;

      setState(() {
        cartItems.clear();
        cartItems.addAll(firebaseCart);

        quantities.clear();

        for (int i = 0; i < cartItems.length; i++) {
          quantities[i] = (cartItems[i]["quantity"] as num?)?.toInt() ?? 1;
        }

        selectedProductIds.removeWhere(
          (id) =>
              !cartItems.any((item) => item["id"]?.toString() == id.toString()),
        );
      });

      CartStorage.saveCart(firebaseCart);
    });
  }

  Future<void> _saveCart() async {
    await CartStorage.saveCart(cartItems);

    if (FirebaseAuth.instance.currentUser != null) {
      await CartFirestore.saveCart(cartItems);
    }
  }

  Future<void> _loadCart() async {
    try {
      final savedCart = await CartFirestore.syncCart();

      cartItems.clear();
      cartItems.addAll(savedCart);

      quantities.clear();
      selectedProductIds.clear();

      for (int i = 0; i < cartItems.length; i++) {
        quantities[i] = (cartItems[i]["quantity"] as num?)?.toInt() ?? 1;
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCart = false;
        });
      }
    }
  }

  double _calculateTotal(int index) {
    final price = (cartItems[index]["price"] as num?)?.toDouble() ?? 0.0;

    return price * (quantities[index] ?? 1);
  }

  double get cartTotal => List.generate(
    cartItems.length,
    (i) => _calculateTotal(i),
  ).fold(0.0, (a, b) => a + b);

  String _getImage(Map<String, dynamic> item) {
    final List images = item["images"] is List ? item["images"] : [];

    if (images.isNotEmpty) {
      final image = images.first?.toString().trim() ?? "";

      if (image.isNotEmpty) {
        return image;
      }
    }

    return item["image"]?.toString().trim() ?? "";
  }

  List<Map<String, dynamic>> get selectedItems {
    return cartItems
        .where((item) => selectedProductIds.contains(item["id"].toString()))
        .toList();
  }

  void toggleProductSelection(String productId) {
    setState(() {
      if (selectedProductIds.contains(productId)) {
        selectedProductIds.remove(productId);
      } else {
        selectedProductIds.add(productId);
      }
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (allSelected) {
        selectedProductIds.clear();
      } else {
        selectedProductIds
          ..clear()
          ..addAll(cartItems.map((item) => item["id"].toString()));
      }
    });
  }

  double get selectedTotal {
    return selectedItems.fold(0.0, (total, item) {
      final price = (item["price"] as num?)?.toDouble() ?? 0.0;

      final quantity = item["quantity"] ?? 1;

      return total + (price * quantity);
    });
  }

  bool get allSelected {
    return cartItems.isNotEmpty &&
        cartItems.every(
          (item) => selectedProductIds.contains(item["id"].toString()),
        );
  }

  Future<int> _getProductStock(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?["stock"] as num?)?.toInt() ?? 0;
  }

  Future<void> _removeFromCart(int index) async {
    final productId = cartItems[index]["id"].toString();

    setState(() {
      selectedProductIds.remove(productId);
      cartItems.removeAt(index);
    });

    quantities.clear();

    for (int i = 0; i < cartItems.length; i++) {
      quantities[i] = (cartItems[i]["quantity"] as num?)?.toInt() ?? 1;
    }

    await _saveCart();
  }

  @override
  void initState() {
    super.initState();

    _loadCart().then((_) {
      if (mounted) {
        _listenToCart();
      }
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.cart),
        leading: widget.showArrowBack ? const CustomBackButton() : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingCart
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : cartItems.isEmpty
            ? Center(
                child: Text(
                  t.yourCartIsEmpty,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1100;
                  final isTablet = width >= 700;

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 32 : 16,
                          8,
                          isDesktop ? 32 : 16,
                          4,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${selectedProductIds.length} ${t.product} ${t.selected}",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                TextButton(
                                  onPressed: toggleSelectAll,
                                  child: Text(
                                    allSelected ? t.deselectAll : t.selectAll,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32 : 0,
                                vertical: 4,
                              ),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];

                                final img = _getImage(item);

                                final productId = item["id"].toString();

                                final isSelected = selectedProductIds.contains(
                                  productId,
                                );

                                final double price =
                                    (item["price"] as num?)?.toDouble() ?? 0;

                                final double oldPrice =
                                    (item["oldPrice"] as num?)?.toDouble() ?? 0;

                                final int discount =
                                    oldPrice > 0 && price < oldPrice
                                    ? (((oldPrice - price) / oldPrice) * 100)
                                          .round()
                                    : 0;

                                return Dismissible(
                                  key: ValueKey(productId),
                                  direction: DismissDirection.startToEnd,
                                  onDismissed: (direction) async {
                                    await _removeFromCart(index);
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onError,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      toggleProductSelection(productId);
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: isSelected
                                            ? BorderSide(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                width: 2,
                                              )
                                            : BorderSide.none,
                                      ),
                                      color: isSelected
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: .25)
                                          : null,
                                      elevation:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0
                                          : 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: isDesktop
                                            ? _buildDesktopCartItem(
                                                context,
                                                item,
                                                img,
                                                productId,
                                                isSelected,
                                                price,
                                                discount,
                                                index,
                                                t,
                                              )
                                            : _buildMobileCartItem(
                                                context,
                                                item,
                                                img,
                                                productId,
                                                isSelected,
                                                price,
                                                discount,
                                                index,
                                                t,
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      _buildCheckoutBar(context, t, isDesktop, isTablet),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMobileCartItem(
    BuildContext context,
    Map<String, dynamic> item,
    String img,
    String productId,
    bool isSelected,
    double price,
    int discount,
    int index,
    AppLocalizations t,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(context, img, discount, size: 80),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${item["price"]}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "\$${_calculateTotal(index).toStringAsFixed(2)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildQuantityControls(context, index, item, t)],
        ),
      ],
    );
  }

  Widget _buildDesktopCartItem(
    BuildContext context,
    Map<String, dynamic> item,
    String img,
    String productId,
    bool isSelected,
    double price,
    int discount,
    int index,
    AppLocalizations t,
  ) {
    return Row(
      children: [
        _buildProductImage(context, img, discount, size: 110),
        const SizedBox(width: 20),
        Expanded(child: _buildProductInfo(context, item, index, price, t)),
        const SizedBox(width: 30),
        _buildQuantityControls(context, index, item, t),
        const SizedBox(width: 40),
        SizedBox(
          width: 130,
          child: Text(
            "\$${_calculateTotal(index).toStringAsFixed(2)}",
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(
    BuildContext context,
    String img,
    int discount, {
    required double size,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: img.isNotEmpty
              ? Image.network(
                  img,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) {
                    return Icon(
                      Icons.image_not_supported_outlined,
                      color: Theme.of(context).colorScheme.outline,
                    );
                  },
                )
              : Icon(
                  Icons.image_outlined,
                  color: Theme.of(context).colorScheme.outline,
                ),
        ),
        if (discount > 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "-$discount%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    double price,
    AppLocalizations t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item["name"] ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "\$${item["price"]}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        _buildQuantityControls(context, index, item, t),
      ],
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    int index,
    Map<String, dynamic> item,
    AppLocalizations t,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.remove,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () async {
              if ((quantities[index] ?? 1) > 1) {
                setState(() {
                  quantities[index] = (quantities[index] ?? 1) - 1;

                  cartItems[index]["quantity"] = quantities[index];
                });

                await _saveCart();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${quantities[index] ?? 1}",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () async {
              final productId = item["id"].toString();

              final currentQuantity = quantities[index] ?? 1;

              final stock = await _getProductStock(productId);

              if (!mounted) return;

              if (stock <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(t.productOutOfStock)));
                return;
              }

              if (currentQuantity >= stock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.onlyItemsAvailable(stock))),
                );
                return;
              }

              setState(() {
                quantities[index] = currentQuantity + 1;

                cartItems[index]["quantity"] = quantities[index];
              });

              await _saveCart();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    AppLocalizations t,
    bool isDesktop,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            t.total,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "\$${cartTotal.toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      height: 50,
                      child: _buildCheckoutButton(context, t),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.total,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          "\$${cartTotal.toStringAsFixed(2)}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _buildCheckoutButton(context, t),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, AppLocalizations t) {
    return ElevatedButton(
      onPressed: () {
        if (selectedProductIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.pleaseSelectAtLeastOneProduct)),
          );
          return;
        }

        // Guest must sign in before checkout.
        if (FirebaseAuth.instance.currentUser == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );

          return;
        }

        final selectedItems = cartItems
            .where((item) => selectedProductIds.contains(item["id"].toString()))
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CheckoutScreen(total: selectedTotal, items: selectedItems),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        t.checkout,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/services/cart_data.dart';
// import 'package:ecomerce_app/services/cart_storage.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';

// import 'package:ecomerce_app/user_dashboard/checkout_screen.dart';
// import 'package:flutter/material.dart';

// class CartPage extends StatefulWidget {
//   final bool showArrowBack;
//   const CartPage({super.key, this.showArrowBack = true});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   final Map<int, int> quantities = {};
//   final Set<String> selectedProductIds = {};

//   Future<void> _loadCart() async {
//     final savedCart = await CartStorage.loadCart();

//     cartItems.clear();
//     cartItems.addAll(savedCart);

//     quantities.clear();
//     selectedProductIds.clear();

//     for (int i = 0; i < cartItems.length; i++) {
//       quantities[i] = cartItems[i]["quantity"] ?? 1;
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   double _calculateTotal(int index) {
//     final price = (cartItems[index]["price"] as num?)?.toDouble() ?? 0.0;
//     return price * (quantities[index] ?? 1);
//   }

//   double get cartTotal => List.generate(
//     cartItems.length,
//     (i) => _calculateTotal(i),
//   ).fold(0.0, (a, b) => a + b);

//   String _getImage(Map<String, dynamic> item) {
//     final List images = item["images"] is List ? item["images"] : [];

//     if (images.isNotEmpty) {
//       final image = images.first?.toString().trim() ?? "";

//       if (image.isNotEmpty) {
//         return image;
//       }
//     }

//     return item["image"]?.toString().trim() ?? "";
//   }

//   List<Map<String, dynamic>> get selectedItems {
//     return cartItems
//         .where((item) => selectedProductIds.contains(item["id"].toString()))
//         .toList();
//   }

//   void toggleProductSelection(String productId) {
//     setState(() {
//       if (selectedProductIds.contains(productId)) {
//         selectedProductIds.remove(productId);
//       } else {
//         selectedProductIds.add(productId);
//       }
//     });
//   }

//   void toggleSelectAll() {
//     setState(() {
//       if (allSelected) {
//         selectedProductIds.clear();
//       } else {
//         selectedProductIds
//           ..clear()
//           ..addAll(cartItems.map((item) => item["id"].toString()));
//       }
//     });
//   }

//   double get selectedTotal {
//     return selectedItems.fold(0.0, (total, item) {
//       final price = (item["price"] as num?)?.toDouble() ?? 0.0;
//       final quantity = item["quantity"] ?? 1;

//       return total + (price * quantity);
//     });
//   }

//   bool get allSelected {
//     return cartItems.isNotEmpty &&
//         cartItems.every(
//           (item) => selectedProductIds.contains(item["id"].toString()),
//         );
//   }

//   Future<int> _getProductStock(String productId) async {
//     final doc = await FirebaseFirestore.instance
//         .collection("products")
//         .doc(productId)
//         .get();

//     if (!doc.exists) return 0;

//     return (doc.data()?["stock"] as num?)?.toInt() ?? 0;
//   }

//   Future<void> _removeFromCart(int index) async {
//     final productId = cartItems[index]["id"].toString();

//     setState(() {
//       selectedProductIds.remove(productId);
//       cartItems.removeAt(index);
//     });

//     quantities.clear();

//     for (int i = 0; i < cartItems.length; i++) {
//       quantities[i] = (cartItems[i]["quantity"] as num?)?.toInt() ?? 1;
//     }

//     await CartStorage.saveCart(cartItems);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadCart();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.cart),
//         leading: widget.showArrowBack ? const CustomBackButton() : null,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: cartItems.isEmpty
//             ? Center(
//                 child: Text(
//                   t.yourCartIsEmpty,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               )
//             : Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "${selectedProductIds.length} ${t.product} ${t.selected}",
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(fontWeight: FontWeight.w600),
//                         ),

//                         TextButton(
//                           onPressed: toggleSelectAll,
//                           child: Text(
//                             allSelected ? t.deselectAll : t.selectAll,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: cartItems.length,
//                       itemBuilder: (context, index) {
//                         final item = cartItems[index];
//                         final img = _getImage(item);

//                         final productId = item["id"].toString();
//                         final isSelected = selectedProductIds.contains(
//                           productId,
//                         );
//                         final double price =
//                             (item["price"] as num?)?.toDouble() ?? 0;

//                         final double oldPrice =
//                             (item["oldPrice"] as num?)?.toDouble() ?? 0;

//                         final int discount = oldPrice > 0 && price < oldPrice
//                             ? (((oldPrice - price) / oldPrice) * 100).round()
//                             : 0;
//                         return Dismissible(
//                           key: ValueKey(productId),

//                           direction: DismissDirection.startToEnd,

//                           onDismissed: (direction) async {
//                             await _removeFromCart(index);
//                           },

//                           background: Container(
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 15,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).colorScheme.error,
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.only(left: 20),
//                             child: Icon(
//                               Icons.delete_outline,
//                               color: Theme.of(context).colorScheme.onError,
//                             ),
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               toggleProductSelection(productId);
//                             },
//                             child: Card(
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 15,
//                                 vertical: 8,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 side: isSelected
//                                     ? BorderSide(
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.primary,
//                                         width: 2,
//                                       )
//                                     : BorderSide.none,
//                               ),
//                               color: isSelected
//                                   ? Theme.of(context)
//                                         .colorScheme
//                                         .primaryContainer
//                                         .withValues(alpha: .25)
//                                   : null,
//                               elevation:
//                                   Theme.of(context).brightness ==
//                                       Brightness.dark
//                                   ? 0
//                                   : 3,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8),
//                                 child: Row(
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         img.isNotEmpty
//                                             ? Container(
//                                                 width: 80,
//                                                 height: 80,
//                                                 decoration: BoxDecoration(
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .surfaceContainerHighest,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                                 padding: const EdgeInsets.all(
//                                                   8,
//                                                 ),
//                                                 child: Image.network(
//                                                   img,
//                                                   fit: BoxFit.contain,
//                                                   loadingBuilder:
//                                                       (
//                                                         context,
//                                                         child,
//                                                         progress,
//                                                       ) {
//                                                         if (progress == null) {
//                                                           return child;
//                                                         }

//                                                         return Center(
//                                                           child: CircularProgressIndicator(
//                                                             strokeWidth: 2,
//                                                             color:
//                                                                 Theme.of(
//                                                                       context,
//                                                                     )
//                                                                     .colorScheme
//                                                                     .primary,
//                                                           ),
//                                                         );
//                                                       },
//                                                   errorBuilder: (_, _, _) {
//                                                     return Icon(
//                                                       Icons
//                                                           .image_not_supported_outlined,
//                                                       color: Theme.of(
//                                                         context,
//                                                       ).colorScheme.outline,
//                                                     );
//                                                   },
//                                                 ),
//                                               )
//                                             : Container(
//                                                 width: 80,
//                                                 height: 80,
//                                                 decoration: BoxDecoration(
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .surfaceContainerHighest,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                                 child: Icon(
//                                                   Icons.image_outlined,
//                                                   color: Theme.of(
//                                                     context,
//                                                   ).colorScheme.outline,
//                                                 ),
//                                               ),

//                                         if (discount > 0)
//                                           Positioned(
//                                             top: 4,
//                                             left: 4,
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 6,
//                                                     vertical: 4,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: Theme.of(
//                                                   context,
//                                                 ).colorScheme.error,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.black
//                                                         .withValues(
//                                                           alpha: 0.18,
//                                                         ),
//                                                     blurRadius: 4,
//                                                     offset: const Offset(0, 2),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Text(
//                                                 "-$discount%",
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             item["name"] ?? "",
//                                             style: Theme.of(
//                                               context,
//                                             ).textTheme.titleMedium,
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             "\$${item["price"]}",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.success,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .surfaceContainerHighest,
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: Icon(
//                                                     Icons.remove,
//                                                     color: Theme.of(
//                                                       context,
//                                                     ).colorScheme.onSurface,
//                                                   ),
//                                                   onPressed: () async {
//                                                     if ((quantities[index] ??
//                                                             1) >
//                                                         1) {
//                                                       setState(() {
//                                                         quantities[index] =
//                                                             (quantities[index] ??
//                                                                 1) -
//                                                             1;
//                                                         cartItems[index]["quantity"] =
//                                                             quantities[index];
//                                                       });

//                                                       await CartStorage.saveCart(
//                                                         cartItems,
//                                                       );
//                                                     }
//                                                   },
//                                                 ),
//                                               ),

//                                               const SizedBox(width: 8),

//                                               Text(
//                                                 "${quantities[index] ?? 1}",
//                                                 style: Theme.of(
//                                                   context,
//                                                 ).textTheme.bodyLarge,
//                                               ),

//                                               const SizedBox(width: 8),

//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .surfaceContainerHighest,
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: Icon(
//                                                     Icons.add,
//                                                     color: Theme.of(
//                                                       context,
//                                                     ).colorScheme.onSurface,
//                                                   ),
//                                                   onPressed: () async {
//                                                     final productId = item["id"]
//                                                         .toString();
//                                                     final currentQuantity =
//                                                         quantities[index] ?? 1;

//                                                     final stock =
//                                                         await _getProductStock(
//                                                           productId,
//                                                         );

//                                                     if (!mounted) return;

//                                                     if (stock <= 0) {
//                                                       ScaffoldMessenger.of(
//                                                         context,
//                                                       ).showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                             t.productOutOfStock,
//                                                           ),
//                                                         ),
//                                                       );
//                                                       return;
//                                                     }

//                                                     if (currentQuantity >=
//                                                         stock) {
//                                                       ScaffoldMessenger.of(
//                                                         context,
//                                                       ).showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                             t.onlyItemsAvailable(
//                                                               stock,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       );
//                                                       return;
//                                                     }

//                                                     setState(() {
//                                                       quantities[index] =
//                                                           currentQuantity + 1;
//                                                       cartItems[index]["quantity"] =
//                                                           quantities[index];
//                                                     });

//                                                     await CartStorage.saveCart(
//                                                       cartItems,
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Text(
//                                       "\$${_calculateTotal(index).toStringAsFixed(2)}",
//                                       style: Theme.of(
//                                         context,
//                                       ).textTheme.titleMedium,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               t.total,
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             Text(
//                               "\$${cartTotal.toStringAsFixed(2)}",
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 10),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (selectedProductIds.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       t.pleaseSelectAtLeastOneProduct,
//                                     ),
//                                   ),
//                                 );
//                                 return;
//                               }

//                               final selectedItems = cartItems
//                                   .where(
//                                     (item) => selectedProductIds.contains(
//                                       item["id"].toString(),
//                                     ),
//                                   )
//                                   .toList();

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => CheckoutScreen(
//                                     total: selectedTotal,
//                                     items: selectedItems,
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.primary,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: Text(
//                               t.checkout,
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
