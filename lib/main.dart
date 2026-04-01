import 'package:ecomerce_app/admin_dashboard/admin_dashboard.dart';
import 'package:ecomerce_app/admin_dashboard/orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/auth/auth_check.dart';
import 'package:ecomerce_app/auth/forgot_password_page.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/auth/register_page.dart';
import 'package:ecomerce_app/auth/splash_screen.dart';
import 'package:ecomerce_app/cart_page.dart';
import 'package:ecomerce_app/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase جاهز
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role'); // admin / user
  runApp(MyApp(initialRole: role));
}

class MyApp extends StatelessWidget {
  final String? initialRole;
  const MyApp({super.key, this.initialRole});

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
      home: const AuthCheck(),

      // الصفحة الرئيسية حسب الدور
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forgot": (context) => const ForgotPasswordPage(),
        "/home": (context) => const HomePage(),
        "/admin": (context) => const AdminDashboard(),
        "/cart": (context) => const CartPage(),
        "/users": (context) => const UsersPage(),
        "/product": (context) => const ProductPage(),
        "/orders": (context) => const OrdersPage(),
        "/splash": (context) => const SplashScreen(),
      },
    );
  }
}
