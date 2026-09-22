import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/auth_check.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Check every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        await _markEmailAsVerified(user);

        timer?.cancel();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthCheck()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _markEmailAsVerified(User user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "emailVerified": true,
    });
  }

  Future checkEmailVerified() async {
    final t = AppLocalizations.of(context)!;

    setState(() => isLoading = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user != null && user.emailVerified) {
      await _markEmailAsVerified(user);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthCheck()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.emailNotVerifiedYet)));
    }
  }

  Future resendEmail() async {
    final t = AppLocalizations.of(context)!;

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verificationEmailSentSuccessfully)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    }
  }

  Future<void> logout() async {
    timer?.cancel();

    await FirebaseAuth.instance.signOut();

    await CartStorage.clearCart();
    await FavoriteStorage.clearFavorites();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(title: Text(t.verifyEmail), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread,
                  size: isDesktop ? 100 : 90,
                  color: Colors.orange,
                ),

                SizedBox(height: isDesktop ? 24 : 20),

                Text(
                  t.verificationEmailMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isDesktop ? 17 : 16),
                ),

                SizedBox(height: isDesktop ? 34 : 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : checkEmailVerified,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(t.iveVerifiedMyEmail),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: resendEmail,
                  child: Text(t.resendVerificationEmail),
                ),

                const SizedBox(height: 12),

                OutlinedButton(onPressed: logout, child: Text(t.logout)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';

// import 'package:ecomerce_app/auth/auth_check.dart';
// import 'package:ecomerce_app/auth/login_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class VerifyEmailPage extends StatefulWidget {
//   const VerifyEmailPage({super.key});

//   @override
//   State<VerifyEmailPage> createState() => _VerifyEmailPageState();
// }

// class _VerifyEmailPageState extends State<VerifyEmailPage> {
//   bool isLoading = false;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();

//     // Check every 5 seconds
//     timer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       await FirebaseAuth.instance.currentUser?.reload();
//       final user = FirebaseAuth.instance.currentUser;

//       if (user != null && user.emailVerified) {
//         timer?.cancel();

//         if (!mounted) return;

//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const AuthCheck()),
//           (route) => false,
//         );
//       }
//     });
//   }

//   Future checkEmailVerified() async {
//     final t = AppLocalizations.of(context)!;

//     setState(() => isLoading = true);

//     await FirebaseAuth.instance.currentUser?.reload();
//     final user = FirebaseAuth.instance.currentUser;

//     if (!mounted) return;

//     setState(() => isLoading = false);

//     if (user != null && user.emailVerified) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const AuthCheck()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.emailNotVerifiedYet)));
//     }
//   }

//   Future resendEmail() async {
//     final t = AppLocalizations.of(context)!;

//     try {
//       await FirebaseAuth.instance.currentUser?.sendEmailVerification();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(t.verificationEmailSentSuccessfully)),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
//     }
//   }

//   Future<void> logout() async {
//     timer?.cancel();

//     await FirebaseAuth.instance.signOut();

//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(title: Text(t.verifyEmail), centerTitle: true),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.mark_email_unread,
//                 size: 90,
//                 color: Colors.orange,
//               ),
//               const SizedBox(height: 20),

//               Text(
//                 t.verificationEmailMessage,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 30),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : checkEmailVerified,
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(t.iveVerifiedMyEmail),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               TextButton(
//                 onPressed: resendEmail,
//                 child: Text(t.resendVerificationEmail),
//               ),

//               const SizedBox(height: 12),

//               OutlinedButton(onPressed: logout, child: Text(t.logout)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
