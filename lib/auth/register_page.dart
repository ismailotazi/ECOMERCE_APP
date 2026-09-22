import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

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
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = t.emailAlreadyInUse;
          break;

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

  // ================= GOOGLE SIGN IN =================

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
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Read role
      final userDoc = await docRef.get();
      final data = userDoc.data();

      final role = data?['role'] as String?;

      if (!mounted) return;

      await context.read<ThemeProvider>().loadUserTheme(
        data?['theme'] as String?,
      );

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
          MaterialPageRoute(builder: (_) => const MainNavUser()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.googleError(e.toString()))));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= CONTINUE AS GUEST =================
  void continueAsGuest() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavUser()),
      (route) => false,
    );
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

                    // CONTINUE AS GUEST
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          t.continueAsGuest,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
// import 'package:ecomerce_app/auth/login_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/localization/language_provider.dart';
// import 'package:ecomerce_app/theme/input_decoration.dart';
// import 'package:ecomerce_app/theme/theme_provider.dart';
// import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmController = TextEditingController();

//   bool hidePassword = true;
//   bool hideConfirm = true;
//   bool isLoading = false;

//   // ================= REGISTER EMAIL =================
//   Future<void> register() async {
//     final t = AppLocalizations.of(context)!;
//     if (isLoading) return;
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();

//       final userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       final user = userCredential.user!;

//       // Send verification email
//       await user.sendEmailVerification();

//       // Save user in Firestore
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'email': email,
//         'role': 'user',
//         'theme': 'system',
//         'language': 'system',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       // Logout until email is verified
//       await FirebaseAuth.instance.signOut();

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.accountCreatedVerifyEmail)));

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//         (route) => false,
//       );
//     } on FirebaseAuthException catch (e) {
//       String message;

//       switch (e.code) {
//         case 'email-already-in-use':
//           message = t.emailAlreadyInUse;
//           break;

//         case 'weak-password':
//           message = t.weakPassword;
//           break;

//         case 'invalid-email':
//           message = t.invalidEmail;
//           break;

//         case 'network-request-failed':
//           message = t.noInternetConnection;
//           break;

//         default:
//           message = e.message ?? t.registrationFailed;
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   // ================= GOOGLE SIGN IN =================

//   Future<void> signInWithGoogle() async {
//     final t = AppLocalizations.of(context)!;
//     setState(() => isLoading = true);

//     try {
//       final GoogleSignIn googleSignIn = GoogleSignIn();

//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         setState(() => isLoading = false);
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithCredential(credential);

//       final user = userCredential.user!;

//       final docRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid);

//       final snapshot = await docRef.get();

//       // إنشاء المستخدم إذا كانت أول مرة
//       if (!snapshot.exists) {
//         await docRef.set({
//           'email': user.email,
//           'name': user.displayName,
//           'role': 'user',
//           'theme': 'system',
//           'language': 'system',
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       }

//       final newSnapshot = await docRef.get();
//       final data = newSnapshot.data();

//       final role = data?['role'] as String?;

//       if (!mounted) return;

//       // Load user preferences from Firestore
//       await context.read<ThemeProvider>().loadUserTheme(
//         data?['theme'] as String?,
//       );

//       await context.read<LanguageProvider>().loadUserLanguage(
//         data?['language'] as String?,
//       );

//       if (!mounted) return;
//       if (role == 'admin') {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const MainNavAdmin()),
//           (route) => false,
//         );
//       } else {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const MainNavUser()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.googleError(e.toString()))));
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(25),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Text(t.createAccount, style: TextStyle(fontSize: 28)),
//                   const SizedBox(height: 25),

//                   // EMAIL
//                   TextFormField(
//                     controller: emailController,
//                     decoration: inputDecoration(
//                       context: context,
//                       label: t.email,
//                       icon: Icons.email_outlined,
//                     ),
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return t.enterEmail;
//                       }

//                       if (!val.contains('@')) {
//                         return t.invalidEmail;
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 15),

//                   // PASSWORD
//                   TextFormField(
//                     controller: passwordController,
//                     obscureText: hidePassword,
//                     decoration: inputDecoration(
//                       context: context,
//                       label: t.password,
//                       icon: Icons.lock_outline,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           hidePassword
//                               ? Icons.visibility_off_rounded
//                               : Icons.visibility_rounded,
//                           color: Theme.of(context).colorScheme.outline,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             hidePassword = !hidePassword;
//                           });
//                         },
//                       ),
//                     ),
//                     validator: (val) {
//                       if (val == null || val.isEmpty) {
//                         return t.enterPassword;
//                       }

//                       if (val.length < 6) {
//                         return t.min6Chars;
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 15),

//                   // CONFIRM
//                   TextFormField(
//                     controller: confirmController,
//                     obscureText: hideConfirm,
//                     decoration: inputDecoration(
//                       context: context,
//                       label: t.confirmPassword,
//                       icon: Icons.lock_outline,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           hideConfirm
//                               ? Icons.visibility_off_rounded
//                               : Icons.visibility_rounded,
//                           color: Theme.of(context).colorScheme.outline,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             hideConfirm = !hideConfirm;
//                           });
//                         },
//                       ),
//                     ),
//                     validator: (val) {
//                       if (val != passwordController.text) {
//                         return t.passwordsDoNotMatch;
//                       }

//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 25),

//                   // REGISTER BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: ElevatedButton(
//                       onPressed: isLoading ? null : register,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         foregroundColor: Theme.of(
//                           context,
//                         ).colorScheme.onPrimary,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: isLoading
//                           ? SizedBox(
//                               width: 22,
//                               height: 22,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Theme.of(context).colorScheme.onPrimary,
//                               ),
//                             )
//                           : Text(
//                               t.createAccount,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),
//                   Text(
//                     t.or,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.outline,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: OutlinedButton.icon(
//                       onPressed: isLoading ? null : signInWithGoogle,
//                       icon: Icon(
//                         Icons.g_mobiledata_rounded,
//                         color: Theme.of(context).colorScheme.primary,
//                         size: 30,
//                       ),
//                       label: Text(
//                         t.continueWithGoogle,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Theme.of(
//                           context,
//                         ).colorScheme.onSurface,
//                         side: BorderSide(
//                           color: Theme.of(context).colorScheme.outlineVariant,
//                         ),
//                         backgroundColor: Theme.of(
//                           context,
//                         ).colorScheme.surfaceContainerHighest,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
