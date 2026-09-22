import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CartStorage {
  static const String _cartKey = "cart_items";

  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();

    final data = cartItems.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList(_cartKey, data);
  }

  static Future<List<Map<String, dynamic>>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(_cartKey);

    if (data == null) return [];

    return data.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_cartKey);
  }
}
