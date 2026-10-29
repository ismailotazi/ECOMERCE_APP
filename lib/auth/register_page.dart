import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final String storeId;

  const RegisterPage({super.key, required this.storeId});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  // ================= REGISTER EMAIL =================
  Future<void> register() async {
    final t = AppLocalizations.of(context)!;
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user!;

      // Send verification email
      await user.sendEmailVerification();

      // Save user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'role': 'user',
        'theme': 'system',
        'language': 'system',
        'emailVerified': false,

        // Keep for backward compatibility
        'storeId': widget.storeId,

        // New multi-store membership
        'stores': {
          widget.storeId: {'role': 'user', 'isActive': true},
        },

        'createdAt': FieldValue.serverTimestamp(),
      });

      // Logout until email is verified
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.accountCreatedVerifyEmail)));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(storeId: widget.storeId)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final existingCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);

          final existingUser = existingCredential.user;

          if (existingUser == null) {
            throw Exception();
          }

          final docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(existingUser.uid);

          final snapshot = await docRef.get();

          if (!snapshot.exists) {
            await FirebaseAuth.instance.signOut();

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
            return;
          }

          final data = snapshot.data()!;
          final role = data['role']?.toString();

          // Admin / SuperAdmin cannot join a store as a normal user.
          if (role != 'user') {
            await FirebaseAuth.instance.signOut();

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(t.emailAlreadyInUse)));
            return;
          }

          final stores = Map<String, dynamic>.from(data['stores'] ?? {});

          bool migratedOldStore = false;

          // Migrate old user who only has storeId.
          if (stores.isEmpty) {
            final oldStoreId = data['storeId']?.toString();

            if (oldStoreId != null && oldStoreId.isNotEmpty) {
              stores[oldStoreId] = {'role': 'user', 'isActive': true};
              migratedOldStore = true;
            }
          }

          final currentStore = stores[widget.storeId];

          // Add user to the selected store if not already a member.
          if (currentStore == null) {
            stores[widget.storeId] = {'role': 'user', 'isActive': true};

            await docRef.update({'stores': stores, 'storeId': widget.storeId});
          } else {
            // Save migration when the selected store already exists.
            if (migratedOldStore) {
              await docRef.update({'stores': stores});
            }

            // Store membership is inactive.
            if (currentStore is Map && currentStore['isActive'] == false) {
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.accountInactive)));
              return;
            }

            // Keep storeId synchronized for backward compatibility.
            if (data['storeId']?.toString() != widget.storeId) {
              await docRef.update({'storeId': widget.storeId});
            }
          }

          // If email is not verified, send verification again.
          if (!existingUser.emailVerified) {
            await existingUser.sendEmailVerification();
          }

          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                existingUser.emailVerified
                    ? t.emailAlreadyInUse
                    : t.accountCreatedVerifyEmail,
              ),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage(storeId: widget.storeId),
            ),
            (route) => false,
          );

          return;
        } on FirebaseAuthException catch (loginError) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          String message;

          switch (loginError.code) {
            case 'wrong-password':
            case 'invalid-credential':
              message = t.emailAlreadyInUse;
              break;

            case 'user-disabled':
              message = t.accountInactive;
              break;

            case 'network-request-failed':
              message = t.noInternetConnection;
              break;

            default:
              message = t.somethingWentWrong;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));

          return;
        }
      }

      String message;

      switch (e.code) {
        case 'weak-password':
          message = t.weakPassword;
          break;

        case 'invalid-email':
          message = t.invalidEmail;
          break;

        case 'network-request-failed':
          message = t.noInternetConnection;
          break;

        default:
          message = e.message ?? t.registrationFailed;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> signInWithGoogle() async {
    final t = AppLocalizations.of(context)!;
    setState(() => isLoading = true);

    try {
      UserCredential userCredential;

      // ================= WEB =================
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope(
          'https://www.googleapis.com/auth/userinfo.email',
        );
        googleProvider.addScope(
          'https://www.googleapis.com/auth/userinfo.profile',
        );

        userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      }
      // ================= ANDROID =================
      else {
        final GoogleSignIn googleSignIn = GoogleSignIn();

        await googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          if (mounted) {
            setState(() => isLoading = false);
          }
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      // ================= FIREBASE USER =================
      final user = userCredential.user!;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final snapshot = await docRef.get();

      // First login
      if (!snapshot.exists) {
        await docRef.set({
          'email': user.email,
          'name': user.displayName,
          'role': 'user',
          'theme': 'system',
          'language': 'system',
          'emailVerified': true,

          // Keep for backward compatibility
          'storeId': widget.storeId,

          // New multi-store membership
          'stores': {
            widget.storeId: {'role': 'user', 'isActive': true},
          },

          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // Read role
      final userDoc = await docRef.get();
      Map<String, dynamic>? data = userDoc.data();

      String? role = data?['role'] as String?;
      // this function dont allow super admin to signin in mainnavuser by wrong
      if (role == 'superAdmin') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

        return;
      }
      if (role == 'admin') {
        final userStoreId = data?['storeId']?.toString();

        if (userStoreId == null || userStoreId.isEmpty) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

          return;
        }

        if (userStoreId != widget.storeId) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

          return;
        }
      } else if (role == 'user') {
        final stores = Map<String, dynamic>.from(data?['stores'] ?? {});

        // ================= OLD USER MIGRATION =================
        // Preserve the old store membership.
        bool migratedOldStore = false;

        if (stores.isEmpty) {
          final oldStoreId = data?['storeId']?.toString();

          if (oldStoreId != null && oldStoreId.isNotEmpty) {
            stores[oldStoreId] = {'role': 'user', 'isActive': true};

            migratedOldStore = true;
          }
        }

        final currentStore = stores[widget.storeId];

        if (currentStore == null) {
          stores[widget.storeId] = {'role': 'user', 'isActive': true};

          await docRef.update({'stores': stores, 'storeId': widget.storeId});
        } else if (migratedOldStore) {
          // Save the migrated membership without replacing the selected store.
          await docRef.update({'stores': stores});
        } else {
          final isActive = currentStore is Map
              ? currentStore['isActive'] != false
              : true;

          if (!isActive) {
            await FirebaseAuth.instance.signOut();

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(t.accountInactive)));

            return;
          }

          if (data?['storeId']?.toString() != widget.storeId) {
            await docRef.update({'storeId': widget.storeId});
          }
        }

        // Re-read after possible store update.
        final updatedDoc = await docRef.get();

        if (!updatedDoc.exists) {
          throw Exception('User data not found');
        }

        data = updatedDoc.data();
        role = data?['role'] as String?;
      }

      if (!mounted) return;

      await context.read<ThemeProvider>().loadUserTheme(
        data?['theme'] as String?,
      );
      if (!mounted) return;
      await context.read<LanguageProvider>().loadUserLanguage(
        data?['language'] as String?,
      );

      if (!mounted) return;

      // ================= NAVIGATION =================
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavAdmin()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavUser(storeId: widget.storeId),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('REGISTER ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      t.createAccount,
                      style: TextStyle(fontSize: isDesktop ? 32 : 28),
                    ),

                    SizedBox(height: isDesktop ? 30 : 25),

                    // EMAIL
                    TextFormField(
                      controller: emailController,
                      decoration: inputDecoration(
                        context: context,
                        label: t.email,
                        icon: Icons.email_outlined,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return t.enterEmail;
                        }

                        if (!val.contains('@')) {
                          return t.invalidEmail;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: inputDecoration(
                        context: context,
                        label: t.password,
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return t.enterPassword;
                        }

                        if (val.length < 6) {
                          return t.min6Chars;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // CONFIRM
                    TextFormField(
                      controller: confirmController,
                      obscureText: hideConfirm,
                      decoration: inputDecoration(
                        context: context,
                        label: t.confirmPassword,
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          onPressed: () {
                            setState(() {
                              hideConfirm = !hideConfirm;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val != passwordController.text) {
                          return t.passwordsDoNotMatch;
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: isDesktop ? 30 : 25),

                    // REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                t.createAccount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      t.or,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : signInWithGoogle,
                        icon: Icon(
                          Icons.g_mobiledata_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                        label: Text(
                          t.continueWithGoogle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final storeId = widget.storeId;

                                await AppPreferences.setSelectedStoreId(
                                  storeId,
                                );

                                if (!context.mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MainNavUser(storeId: storeId),
                                  ),
                                  (route) => false,
                                );
                              },
                        child: Text(
                          t.continueAsGuest,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            t.alreadyHaveAnAccount,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LoginPage(storeId: widget.storeId),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            t.signIn,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
