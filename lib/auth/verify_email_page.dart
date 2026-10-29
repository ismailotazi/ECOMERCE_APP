import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/auth/store_selection_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/main.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? storeId;

  const VerifyEmailPage({super.key, required this.storeId});

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
      try {
        await FirebaseAuth.instance.currentUser?.reload();
      } catch (e) {
        debugPrint('Verification reload error: $e');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        await _markEmailAsVerified(user);

        timer?.cancel();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthStartupPage()),
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

  Future<void> checkEmailVerified() async {
    final t = AppLocalizations.of(context)!;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (e) {
      debugPrint('Verification check error: $e');
    }

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user != null && user.emailVerified) {
      await _markEmailAsVerified(user);

      timer?.cancel();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthStartupPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.emailNotVerifiedYet)));
    }
  }

  Future<void> resendEmail() async {
    final t = AppLocalizations.of(context)!;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verificationEmailSentSuccessfully)),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('RESEND VERIFICATION ERROR: ${e.code} - ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    }
  }

  Future<void> logout() async {
    timer?.cancel();

    try {
      await FirebaseAuth.instance.signOut();

      await CartStorage.clearCart();
      await FavoriteStorage.clearFavorites();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StoreSelectionPage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');

      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    }
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
