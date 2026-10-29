import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';

import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

class UserEditProfile extends StatefulWidget {
  const UserEditProfile({super.key});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  // Profile Image

  String? savedPhone;

  // User Information

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  // Firebase / Form

  final user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;

  String? completePhoneNumber;

  // save profile

  Future<void> saveProfile() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    completePhoneNumber ??= savedPhone;

    if (completePhoneNumber == null || completePhoneNumber!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.pleaseEnterPhoneNumber)));
      return;
    }

    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),

        "email": user!.email,
        "phone": completePhoneNumber ?? "",

        "country": countryController.text.trim(),

        "city": cityController.text.trim(),
        "address": addressController.text.trim(),

        "updatedAt": FieldValue.serverTimestamp(),
        "isProfileCompleted": true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.profileUpdatedSuccessfully)));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    }
  }

  // load profile
  Future<void> loadUserData() async {
    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (!doc.exists) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final data = doc.data()!;

      firstNameController.text = data["firstName"]?.toString() ?? "";
      lastNameController.text = data["lastName"]?.toString() ?? "";

      emailController.text = data["email"]?.toString() ?? "";
      savedPhone = data["phone"]?.toString().trim();

      countryController.text = data["country"]?.toString() ?? "";
      cityController.text = data["city"]?.toString() ?? "";
      addressController.text = data["address"]?.toString() ?? "";

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("LOAD PROFILE ERROR: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();

    emailController.dispose();
    // phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.editProfile),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isDesktop = width >= 1100;
            final bool isTablet = width >= 700 && width < 1100;

            final double horizontalPadding = isDesktop
                ? 32
                : isTablet
                ? 24
                : 20;

            final double maxContentWidth = isDesktop
                ? 950
                : isTablet
                ? 850
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    children: [
                      // PERSONAL INFORMATION
                      Card(
                        elevation: 0,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 24 : 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.personalInformation,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                controller: firstNameController,
                                validator: (value) {
                                  final name = value?.trim() ?? '';

                                  if (name.isEmpty) {
                                    return t.firstNameIsRequired;
                                  }

                                  if (name.length < 2) {
                                    return t.firstNameMinLength;
                                  }

                                  if (name.length > 30) {
                                    return t.firstNameMaxLength;
                                  }

                                  if (!RegExp(
                                    r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
                                  ).hasMatch(name)) {
                                    return t.validFirstName;
                                  }

                                  return null;
                                },
                                decoration: inputDecoration(
                                  context: context,
                                  label: t.firstName,
                                  icon: Icons.person_outline,
                                ),
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: lastNameController,
                                validator: (value) {
                                  final name = value?.trim() ?? '';

                                  if (name.isEmpty) {
                                    return t.lastNameIsRequired;
                                  }

                                  if (name.length < 2) {
                                    return t.lastNameMinLength;
                                  }

                                  if (name.length > 30) {
                                    return t.lastNameMaxLength;
                                  }

                                  if (!RegExp(
                                    r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
                                  ).hasMatch(name)) {
                                    return t.validLastName;
                                  }

                                  return null;
                                },
                                decoration: inputDecoration(
                                  context: context,
                                  label: t.lastName,
                                  icon: Icons.person_outline,
                                ),
                              ),

                              const SizedBox(height: 15),

                              TextField(
                                controller: emailController,
                                enabled: false,
                                decoration: inputDecoration(
                                  context: context,
                                  label: t.email,
                                  icon: Icons.email_outlined,
                                  suffixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

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

                              const SizedBox(height: 25),

                              // SHIPPING ADDRESS
                              Card(
                                elevation: 0,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isDesktop ? 20 : 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.shippingAddress,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: countryController,
                                        validator: (value) {
                                          final country = value?.trim() ?? '';

                                          if (country.isEmpty) {
                                            return t.countryIsRequired;
                                          }

                                          if (country.length < 2) {
                                            return t.countryNameTooShort;
                                          }

                                          if (country.length > 60) {
                                            return t.countryNameTooLong;
                                          }

                                          if (!RegExp(
                                            r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                                          ).hasMatch(country)) {
                                            return t.validCountryName;
                                          }

                                          return null;
                                        },
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.countryRequired,
                                          icon: Icons.location_city,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: cityController,
                                        validator: (value) {
                                          final city = value?.trim() ?? '';

                                          if (city.isEmpty) {
                                            return t.cityIsRequired;
                                          }

                                          if (city.length < 2) {
                                            return t.cityNameTooShort;
                                          }

                                          if (city.length > 60) {
                                            return t.cityNameTooLong;
                                          }

                                          if (!RegExp(
                                            r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                                          ).hasMatch(city)) {
                                            return t.validCityName;
                                          }

                                          return null;
                                        },
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.cityRequired,
                                          icon: Icons.location_city,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: addressController,
                                        maxLines: 2,
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.streetAddressOptional,
                                          icon: Icons.home_outlined,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton.icon(
                                          onPressed: saveProfile,
                                          icon: Icon(
                                            Icons.save,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                          label: Text(
                                            t.saveChanges,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            foregroundColor: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
