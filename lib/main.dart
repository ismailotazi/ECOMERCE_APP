import 'package:ecomerce_app/admin_dashboard/admin_dashboard.dart';
import 'package:ecomerce_app/admin_dashboard/orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/auth/forgot_password_page.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/auth/register_page.dart';
import 'package:ecomerce_app/auth/splash_screen.dart';
import 'package:ecomerce_app/cart_page.dart';
import 'package:ecomerce_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role');
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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreen(),
      routes: {
        "login": (context) => const LoginPage(),
        "register": (context) => const RegisterPage(),
        "forgot": (context) => const ForgotPasswordPage(),
        "home": (context) => const HomePage(),
        "admin": (context) => const AdminDashboard(),
        "cart": (context) => const CartPage(),
        "users": (context) => const UsersPage(),
        "product": (context) => const ProductPage(),
        "orders": (context) => const OrdersPage(),
      },
    );
  }
}
