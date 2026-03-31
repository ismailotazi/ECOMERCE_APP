import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), checkUser);
  }

  Future<void> checkUser() async {
    final user = FirebaseAuth.instance.currentUser;

    // ❌ Ila user ma kaynach → Login
    if (user == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    try {
      // ✅ Nجيب role من Firestore
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final role = doc.data()?["role"] ?? "user";

      if (!mounted) return;

      // 🔥 Navigate حسب role
      if (role == "admin") {
        Navigator.pushReplacementNamed(context, "/admin");
      } else {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      // ❌ Error → رجع Login
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8C00), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: size.width * 0.15,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset("images/splash.png"),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // APP NAME
              const Text(
                "MiloStore",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Best Shopping Experience",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              // LOADING
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
