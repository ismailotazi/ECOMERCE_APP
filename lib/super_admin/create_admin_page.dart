import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CreateAdminPage extends StatefulWidget {
  const CreateAdminPage({super.key});

  @override
  State<CreateAdminPage> createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends State<CreateAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  String? selectedStoreId;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createAdmin() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedStoreId == null || selectedStoreId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.pleaseSelectStore),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    FirebaseApp? secondaryApp;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('SuperAdmin is not authenticated.');
      }

      secondaryApp = await Firebase.initializeApp(
        name: 'createAdminApp',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final newAdmin = credential.user;

      if (newAdmin == null) {
        throw Exception('Admin account could not be created.');
      }
      try {
        await newAdmin.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newAdmin.uid)
            .set({
              'firstName': firstNameController.text.trim(),
              'lastName': lastNameController.text.trim(),
              'email': emailController.text.trim(),
              'role': 'admin',
              'storeId': selectedStoreId!.trim(),
              'isActive': true,
              'emailVerified': false,
              'createdAt': FieldValue.serverTimestamp(),
            });

        await secondaryAuth.signOut();
      } catch (e) {
        // Firestore creation failed after Auth account was created.
        // Remove the newly created Auth account to avoid an orphan account.
        try {
          await newAdmin.delete();
        } catch (deleteError) {
          debugPrint('ORPHAN ADMIN DELETE ERROR: $deleteError');
        }

        rethrow;
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(t.adminCreatedSuccessfully),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint('CREATE ADMIN AUTH ERROR: ${e.code} - ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(e.message ?? t.failedToCreateAdmin),
        ),
      );
    } on FirebaseException catch (e) {
      debugPrint('CREATE ADMIN FIREBASE ERROR: ${e.code} - ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(e.message ?? t.failedToCreateAdmin),
        ),
      );
    } catch (e) {
      debugPrint('CREATE ADMIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.failedToCreateAdmin),
        ),
      );
    } finally {
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (e) {
          debugPrint('SECONDARY APP DELETE ERROR: $e');
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.createAdmin,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1100;
            final isTablet = width >= 700 && width < 1100;

            final horizontalPadding = isDesktop
                ? 40.0
                : isTablet
                ? 32.0
                : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isDesktop ? 40 : 28,
                    ),
                    children: [
                      // =========================
                      // HEADER
                      // =========================
                      Center(
                        child: Container(
                          width: isDesktop ? 72 : 64,
                          height: isDesktop ? 72 : 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            size: isDesktop ? 38 : 34,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        t.createAdministrator,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        t.createAdminAssignStore,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // FIRST NAME
                      // =========================
                      TextFormField(
                        controller: firstNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: t.firstName,
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.pleaseEnterFirstName;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // LAST NAME
                      // =========================
                      TextFormField(
                        controller: lastNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: t.lastName,
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.pleaseEnterLastName;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // EMAIL
                      // =========================
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: t.email,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return t.pleaseEnterEmail;
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex.hasMatch(email)) {
                            return t.pleaseEnterValidEmail;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // PASSWORD
                      // =========================
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: t.password,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value ?? '';

                          if (password.isEmpty) {
                            return t.pleaseEnterPassword;
                          }

                          if (password.length < 6) {
                            return t.passwordMinCharacters;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // STORE
                      // =========================
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('stores')
                            .where('isActive', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: LinearProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              t.unableToLoadStores,
                              style: TextStyle(color: colorScheme.error),
                            );
                          }

                          final stores = snapshot.data?.docs ?? [];

                          if (stores.isEmpty) {
                            return Text(
                              t.noActiveStoresAvailable,
                              style: TextStyle(color: colorScheme.error),
                            );
                          }
                          return DropdownButtonFormField<String>(
                            initialValue: selectedStoreId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: t.assignStore,
                              prefixIcon: Icon(Icons.storefront_outlined),
                            ),
                            items: stores.map((store) {
                              final data = store.data();

                              final storeName =
                                  data['name']?.toString().trim().isNotEmpty ==
                                      true
                                  ? data['name'].toString().trim()
                                  : store.id;

                              return DropdownMenuItem<String>(
                                value: store.id,
                                child: Text(
                                  '$storeName (${store.id})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedStoreId = value;
                                    });
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return t.pleaseSelectStore;
                              }

                              return null;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // CREATE BUTTON
                      // =========================
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : createAdmin,
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  t.createAdmin,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
