import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';

import 'package:ecomerce_app/user_dashboard/cart_page.dart';
import 'package:ecomerce_app/user_dashboard/home_page.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:ecomerce_app/user_dashboard/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ecomerce_app/auth/auth_check.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/auth/register_page.dart';
import 'package:ecomerce_app/auth/forgot_password_page.dart';

import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecom App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),

      initialRoute: "/",

      routes: {
        "/": (context) => const AuthCheck(),

        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forgot": (context) => const ForgotPasswordPage(),

        // User
        "/main": (context) => const MainNavUser(),
        "/home": (context) => const HomePage(),
        "/cart": (context) => const CartPage(),

        // Admin
        "/mainAdmin": (context) => const MainNavAdmin(),

        "/users": (context) => const UsersPage(),
        "/product": (context) => const ProductPage(),
        "/orders": (context) => const OrdersPage(),
      },
    );
  }
}
