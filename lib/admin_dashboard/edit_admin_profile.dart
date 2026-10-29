import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  String? completePhoneNumber;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  // pick image

  String? savedPhone;

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
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection("users").doc(user!.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('Admin profile not found.');
      }

      final userData = userDoc.data();
      final storeId = userData?["storeId"]?.toString().trim();

      final phone = completePhoneNumber!.trim();

      final batch = firestore.batch();

      batch.set(userRef, {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phone,
        "updatedAt": FieldValue.serverTimestamp(),
        "isProfileCompleted": true,
      }, SetOptions(merge: true));

      if (storeId != null && storeId.isNotEmpty) {
        final storeRef = firestore.collection("stores").doc(storeId);

        batch.update(storeRef, {
          "whatsappNumber": phone.replaceAll(RegExp(r'[^0-9]'), ''),
        });
      }

      await batch.commit();

      savedPhone = phone;
      completePhoneNumber = phone;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            t.profileUpdatedSuccessfully,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('SAVE ADMIN PROFILE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            e.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
    }
  }

  // load profile
  Future<void> loadUserData() async {
    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final data = doc.data();

      if (data == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      firstNameController.text = data["firstName"]?.toString() ?? "";
      lastNameController.text = data["lastName"]?.toString() ?? "";

      emailController.text = data["email"]?.toString() ?? "";
      savedPhone = data["phone"]?.toString().trim();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('LOAD ADMIN PROFILE ERROR: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.somethingWentWrong),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();

    emailController.dispose();

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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 28.0 : 16.0;

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
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                children: [
                  SizedBox(height: isDesktop ? 20 : 16),

                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: Theme.of(context).brightness == Brightness.dark
                        ? 0
                        : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 26 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.personalInformation,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: isDesktop ? 22 : 20),

                          TextFormField(
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.firstNameRequired;
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
                              if (value == null || value.trim().isEmpty) {
                                return t.lastNameIsRequired;
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
                                ).colorScheme.onSurfaceVariant,
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

                          SizedBox(height: isDesktop ? 28 : 25),

                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 58 : 55,
                            child: ElevatedButton.icon(
                              onPressed: saveProfile,

                              icon: Icon(
                                Icons.save,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),

                              label: Text(
                                t.saveChanges,
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 20 : 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
