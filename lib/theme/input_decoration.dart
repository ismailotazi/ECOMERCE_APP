import 'package:flutter/material.dart';

InputDecoration inputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return InputDecoration(
    labelText: label,

    labelStyle: TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    ),

    floatingLabelStyle: TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    ),

    prefixIcon: Icon(icon, color: colorScheme.primary),

    suffixIcon: suffixIcon,

    filled: true,
    fillColor: colorScheme.surfaceContainerHighest,

    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    ),
  );
}
