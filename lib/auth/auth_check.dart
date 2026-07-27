import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';

import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'verify_email_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint("Error getting role: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // User not logged in
        if (user == null) {
          return const LoginPage();
        }

        // Email not verified
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }

        return FutureBuilder<String?>(
          future: getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text("Something went wrong")),
              );
            }

            final role = roleSnapshot.data;

            switch (role) {
              case 'admin':
                return const MainNavAdmin();

              case 'user':
                return const MainNavUser();

              default:
                // إذا ماكانش role أو كانت خاطئة
                return const LoginPage();
            }
          },
        );
      },
    );
  }
}
