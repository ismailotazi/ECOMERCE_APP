import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';

import 'package:ecomerce_app/auth/verify_email_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/main.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/super_admin/main_nav_super_admin.dart';

import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecomerce_app/auth/register_page.dart';
import 'package:ecomerce_app/auth/forgot_password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final String? storeId;

  const LoginPage({super.key, this.storeId});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  String? selectedStoreId;

  Stream<QuerySnapshot<Map<String, dynamic>>> get activeStoresStream {
    return FirebaseFirestore.instance
        .collection('stores')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // ================= EMAIL LOGIN =================
  Future login() async {
    final t = AppLocalizations.of(context)!;

    final storeId = selectedStoreId;

    if (!_formKey.currentState!.validate()) return;
    AuthFlowState.isLoginInProgress = true;
    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user == null) {
        throw Exception('User not found');
      }

      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not found');
      }

      // ================= READ USER FROM FIRESTORE =================
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.userDataNotFound)));

        return;
      }

      final data = doc.data();
      final role = data?['role']?.toString();

      // ================= SYNC EMAIL VERIFICATION =================
      if (user.emailVerified && data?['emailVerified'] != true) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': true});
      }
      // ================= ADMIN ACTIVE CHECK =================

      if (role == 'admin') {
        final isActive = data?['isActive'] == true;

        if (!isActive) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.accountInactive)));

          return;
        }
      }

      // ================= NORMAL USER / ADMIN EMAIL VERIFICATION =================

      if (!user.emailVerified) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailPage(
              storeId: data?['storeId']?.toString() ?? widget.storeId,
            ),
          ),
          (route) => false,
        );

        return;
      }
      // ================= USER STORE MEMBERSHIP CHECK =================

      if (role == 'user') {
        final stores = Map<String, dynamic>.from(data?['stores'] ?? {});

        // Migrate old users who only have top-level storeId
        if (stores.isEmpty) {
          final oldStoreId = data?['storeId']?.toString();

          if (oldStoreId != null && oldStoreId.isNotEmpty) {
            stores[oldStoreId] = {'role': 'user', 'isActive': true};

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'stores': stores});
          }
        }

        if (storeId == null || storeId.isEmpty) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

          return;
        }

        final currentStore = stores[storeId];

        if (currentStore == null) {
          stores[storeId] = {'role': 'user', 'isActive': true};

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'stores': stores, 'storeId': storeId});
        }

        if (currentStore is Map && currentStore['isActive'] == false) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.accountInactive)));

          return;
        }
      }

      // ================= ADMIN STORE CHECK =================

      if (role == 'admin') {
        final adminStoreId = data?['storeId']?.toString();

        if (adminStoreId == null ||
            adminStoreId.isEmpty ||
            adminStoreId != storeId) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

          return;
        }
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

      if (role == 'superAdmin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavSuperAdmin()),
          (route) => false,
        );
      } else if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavAdmin()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainNavUser(storeId: storeId)),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = t.userNotFound;
          break;

        case 'wrong-password':
          message = t.wrongPassword;
          break;

        case 'invalid-email':
          message = t.invalidEmail;
          break;

        default:
          message = t.loginFailed;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, stackTrace) {
      debugPrint('🔥 LOGIN STACKTRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('LOGIN ERROR: $e')));
    } finally {
      AuthFlowState.isLoginInProgress = false;

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> signInWithGoogle() async {
    final storeId = selectedStoreId;

    final t = AppLocalizations.of(context)!;

    if (storeId == null || storeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.selectStoreToContinue)));
      return;
    }

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
      debugPrint('GOOGLE UID: ${user.uid}');
      debugPrint('GOOGLE EMAIL: ${user.email}');

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
          'storeId': storeId,
          'stores': {
            storeId: {'role': 'user', 'isActive': true},
          },
          'emailVerified': true,
          'theme': 'system',
          'language': 'system',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Read role
      final userDoc = await docRef.get();
      final data = userDoc.data();

      final role = data?['role'] as String?;
      // Verify that admin is logging into the correct store.
      if (role == 'admin') {
        final adminStoreId = data?['storeId']?.toString();

        if (adminStoreId == null ||
            adminStoreId.isEmpty ||
            adminStoreId != storeId) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

          return;
        }
      }
      // ================= ADMIN ACTIVE CHECK =================
      if (role == 'admin' && data?['isActive'] != true) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.accountInactive)));

        return;
      }

      // ================= SUPER ADMIN =================
      if (role == 'superAdmin') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

        return;
      }
      final stores = Map<String, dynamic>.from(data?['stores'] ?? {});

      // ================= OLD USER MIGRATION =================
      // Old users only have storeId.
      if (role == 'user' && stores.isEmpty) {
        final oldStoreId = data?['storeId']?.toString();

        if (oldStoreId != null && oldStoreId.isNotEmpty) {
          stores[oldStoreId] = {'role': role ?? 'user', 'isActive': true};

          await docRef.update({'stores': stores});
        }
      }

      if (role == 'user') {
        final currentStore = stores[storeId];

        if (currentStore == null) {
          stores[storeId] = {'role': 'user', 'isActive': true};

          await docRef.update({'stores': stores, 'storeId': storeId});
        }

        final isStoreActive = currentStore is Map
            ? currentStore['isActive'] != false
            : true;

        if (!isStoreActive) {
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.accountInactive)));

          return;
        }
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
          MaterialPageRoute(builder: (_) => MainNavUser(storeId: storeId)),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('GOOGLE SIGN IN ERROR: $e');
      debugPrint('GOOGLE SIGN IN STACK: $stackTrace');

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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 25,
                vertical: isDesktop ? 32 : 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32 : 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.login,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),

                          SizedBox(height: isDesktop ? 30 : 25),

                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: activeStoresStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(t.somethingWentWrong);
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LinearProgressIndicator();
                              }

                              final stores = snapshot.data?.docs ?? [];

                              if (stores.isEmpty) {
                                return Text(t.noStoresAvailableAtMoment);
                              }

                              // Select the current store automatically when available.
                              final currentStoreExists = stores.any(
                                (store) => store.id == selectedStoreId,
                              );

                              if (!currentStoreExists) {
                                selectedStoreId =
                                    stores.any(
                                      (store) => store.id == widget.storeId,
                                    )
                                    ? widget.storeId
                                    : stores.first.id;
                              }

                              return DropdownButtonFormField<String>(
                                value: selectedStoreId,
                                isExpanded: true,
                                decoration: inputDecoration(
                                  context: context,
                                  label: t.chooseYourStore,
                                  icon: Icons.storefront_outlined,
                                ),
                                items: stores.map((store) {
                                  final data = store.data();
                                  final name = data['name']?.toString().trim();

                                  return DropdownMenuItem<String>(
                                    value: store.id,
                                    child: Text(
                                      name != null && name.isNotEmpty
                                          ? name
                                          : store.id,
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
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          // EMAIL
                          TextFormField(
                            controller: emailController,
                            decoration: inputDecoration(
                              context: context,
                              label: t.email,
                              icon: Icons.email_outlined,
                            ),
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
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (selectedStoreId != null &&
                              selectedStoreId!.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(
                                        storeId: selectedStoreId!,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  t.forgotPassword,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 15),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
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
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    )
                                  : Text(
                                      t.login,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            t.or,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                elevation: 0,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: Icon(
                                Icons.login_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                t.continueWithGoogle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final storeId = selectedStoreId;
                                      final t = AppLocalizations.of(context)!;

                                      if (storeId == null || storeId.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              t.selectStoreToContinue,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Check whether a Firebase account is already signed in.
                                      final currentUser =
                                          FirebaseAuth.instance.currentUser;

                                      if (currentUser != null) {
                                        final userDoc = await FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(currentUser.uid)
                                            .get();

                                        if (!context.mounted) return;

                                        final data = userDoc.data();
                                        final role = data?['role']?.toString();

                                        if (role == 'superAdmin') {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const MainNavSuperAdmin(),
                                            ),
                                            (route) => false,
                                          );
                                          return;
                                        }

                                        if (role == 'admin') {
                                          final adminStoreId = data?['storeId']
                                              ?.toString();

                                          if (data?['isActive'] != true ||
                                              adminStoreId == null ||
                                              adminStoreId.isEmpty ||
                                              adminStoreId != storeId) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  t.somethingWentWrong,
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const MainNavAdmin(),
                                            ),
                                            (route) => false,
                                          );
                                          return;
                                        }

                                        if (role != 'user') {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                t.somethingWentWrong,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                      }

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
                                  t.dontHaveAnAccount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 5),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        final storeId = selectedStoreId;

                                        if (storeId == null ||
                                            storeId.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.selectStoreToContinue,
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                RegisterPage(storeId: storeId),
                                          ),
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  t.register,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
          ),
        ],
      ),
    );
  }
}
