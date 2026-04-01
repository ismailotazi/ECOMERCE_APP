import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      future: user.reload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Reload user after future
        user = FirebaseAuth.instance.currentUser;

        if (user != null && user!.emailVerified) {
          return const HomePage();
        } else {
          FirebaseAuth.instance.signOut();
          return const LoginPage();
        }
      },
    );
  }
}
