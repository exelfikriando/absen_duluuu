import 'package:flutter/material.dart';

class AppColors {
  // Warna Biru Kehijauan Cerah (Teal / Cyan)
  static const Color primary = Color(0xFF00B4DB); // Bright Cyan
  static const Color accent = Color(0xFF0083B0);  // Deep Teal
  static const Color background = Color(0xFFF0F9FA); // Very Light Cyan Background
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A3C40); // Dark Teal Text
  static const Color textSecondary = Color(0xFF50727B); // Muted Teal Text
  static const Color success = Color(0xFF00C897); // Mint Green
  static const Color error = Color(0xFFFF4B5C); // Coral Red
}

class AppDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration gradientHeader = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.accent],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(35),
      bottomRight: Radius.circular(35),
    ),
  );
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
