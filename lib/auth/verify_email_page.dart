import 'dart:async';

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
        timer?.cancel();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user != null && user.emailVerified) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email is not verified yet.")),
      );
    }
  }

  Future<void> resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> logout() async {
    timer?.cancel();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 90,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),

              const Text(
                "We've sent a verification email to your inbox.\nPlease verify your email before continuing.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : checkEmailVerified,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("I've Verified My Email"),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: resendEmail,
                child: const Text("Resend Verification Email"),
              ),

              const SizedBox(height: 12),

              OutlinedButton(onPressed: logout, child: const Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }
}
