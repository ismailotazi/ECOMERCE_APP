import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/services/cart_firestore.dart';
import 'package:ecomerce_app/services/favorite_firestore.dart';
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
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  // ================= EMAIL LOGIN =================
  Future login() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      // Verify email
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.verifyYourEmailFirst),
            action: SnackBarAction(
              label: t.resend,
              onPressed: () async {
                await user!.sendEmailVerification();
              },
            ),
          ),
        );

        return;
      }

      // Read user from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
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
      final role = doc.data()?['role'] as String?;

      if (!mounted) return;

      await context.read<ThemeProvider>().loadUserTheme(
        data?['theme'] as String?,
      );

      await context.read<LanguageProvider>().loadUserLanguage(
        data?['language'] as String?,
      );
      // ================= MERGE GUEST DATA =================
      await FavoriteFirestore.mergeGuestFavorites();
      await CartFirestore.syncCart();
      if (!mounted) return;

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
      // ================= MERGE GUEST DATA =================
      await FavoriteFirestore.mergeGuestFavorites();
      await CartFirestore.syncCart();
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

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                t.forgotPassword,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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

                          const SizedBox(height: 20),
                          // ================= GUEST =================
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
                                style: TextStyle(
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
                              Text(
                                t.dontHaveAnAccount,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  t.register,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/localization/language_provider.dart';
// import 'package:ecomerce_app/theme/input_decoration.dart';
// import 'package:ecomerce_app/theme/theme_provider.dart';
// import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ecomerce_app/auth/register_page.dart';
// import 'package:ecomerce_app/auth/forgot_password_page.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;
//   bool hidePassword = true;

//   // ================= EMAIL LOGIN =================
//   Future login() async {
//     final t = AppLocalizations.of(context)!;

//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();

//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);

//       User? user = userCredential.user;

//       await user?.reload();
//       user = FirebaseAuth.instance.currentUser;

//       // Verify email
//       if (user != null && !user.emailVerified) {
//         await FirebaseAuth.instance.signOut();

//         if (!mounted) return;

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(t.verifyYourEmailFirst),
//             action: SnackBarAction(
//               label: t.resend,
//               onPressed: () async {
//                 await user!.sendEmailVerification();
//               },
//             ),
//           ),
//         );

//         return;
//       }

//       // Read user from Firestore
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       if (!doc.exists) {
//         await FirebaseAuth.instance.signOut();

//         if (!mounted) return;

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(t.userDataNotFound)));

//         return;
//       }
//       final data = doc.data();
//       final role = doc.data()?['role'] as String?;

//       if (!mounted) return;

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
//     } on FirebaseAuthException catch (e) {
//       String message;

//       switch (e.code) {
//         case 'user-not-found':
//           message = t.userNotFound;
//           break;

//         case 'wrong-password':
//           message = t.wrongPassword;
//           break;

//         case 'invalid-email':
//           message = t.invalidEmail;
//           break;

//         default:
//           message = t.loginFailed;
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

//   // ================= GOOGLE LOGIN =================
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

//       // First login
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

//       // Read role
//       final userDoc = await docRef.get();
//       final data = userDoc.data();

//       final role = data?['role'] as String?;

//       if (!mounted) return;

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
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(context).colorScheme.surface,
//                   Theme.of(context).colorScheme.surfaceContainer,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: Card(
//                 elevation: 0,
//                 color: Theme.of(context).colorScheme.surfaceContainer,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   side: BorderSide(
//                     color: Theme.of(context).colorScheme.outlineVariant,
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(25),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           t.login,
//                           style: Theme.of(context).textTheme.headlineMedium
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).colorScheme.onSurface,
//                               ),
//                         ),
//                         const SizedBox(height: 25),

//                         // EMAIL
//                         TextFormField(
//                           controller: emailController,
//                           decoration: inputDecoration(
//                             context: context,
//                             label: t.email,
//                             icon: Icons.email_outlined,
//                           ),
//                         ),
//                         const SizedBox(height: 15),

//                         // PASSWORD
//                         TextFormField(
//                           controller: passwordController,
//                           obscureText: hidePassword,
//                           decoration: inputDecoration(
//                             context: context,
//                             label: t.password,
//                             icon: Icons.lock_outline,
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 hidePassword
//                                     ? Icons.visibility_off_outlined
//                                     : Icons.visibility_outlined,
//                                 color: Theme.of(context).colorScheme.outline,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   hidePassword = !hidePassword;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => const ForgotPasswordPage(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               t.forgotPassword,
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 15),

//                         // LOGIN BUTTON
//                         SizedBox(
//                           width: double.infinity,
//                           height: 55,
//                           child: ElevatedButton(
//                             onPressed: isLoading ? null : login,
//                             style: ElevatedButton.styleFrom(
//                               elevation: 0,
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.primary,
//                               foregroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.onPrimary,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             child: isLoading
//                                 ? CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                   )
//                                 : Text(
//                                     t.login,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         Text(
//                           t.or,
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(
//                                 color: Theme.of(context).colorScheme.outline,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                         ),

//                         const SizedBox(height: 20),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 55,
//                           child: OutlinedButton.icon(
//                             onPressed: isLoading ? null : signInWithGoogle,
//                             style: OutlinedButton.styleFrom(
//                               elevation: 0,
//                               foregroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.onSurface,
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.surfaceContainerHighest,
//                               side: BorderSide(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.outlineVariant,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             icon: Icon(
//                               Icons.login_rounded,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             label: Text(
//                               t.continueWithGoogle,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               t.dontHaveAnAccount,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const RegisterPage(),
//                                   ),
//                                 );
//                               },
//                               child: Text(
//                                 t.register,
//                                 style: Theme.of(context).textTheme.bodyMedium
//                                     ?.copyWith(
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.primary,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
