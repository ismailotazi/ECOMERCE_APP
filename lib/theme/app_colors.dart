import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //========================
  // BRAND
  //========================

  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF5B4CF5);
  static const secondary = Color(0xFF8B5CF6);

  //========================
  // STATUS
  //========================

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  //========================
  // LIGHT
  //========================

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Colors.white;
  static const lightCard = Colors.white;

  static const lightText = Color(0xFF111827);
  static const lightSecondaryText = Color(0xFF6B7280);

  static const lightBorder = Color(0xFFE5E7EB);

  //========================
  // DARK
  //========================

  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF1E293B);

  static const darkText = Colors.white;
  static const darkSecondaryText = Color(0xFF94A3B8);

  static const darkBorder = Color(0xFF334155);

  //========================
  // COMMON
  //========================

  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  static const divider = Color(0xFFE5E7EB);

  //========================
  // GRADIENTS
  //========================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
}
