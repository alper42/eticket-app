import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette – Deep Noir + Electric Violet + Gold
  static const Color background    = Color(0xFF0A0A0F);
  static const Color surface       = Color(0xFF13131C);
  static const Color surfaceLight  = Color(0xFF1C1C2A);
  static const Color primary       = Color(0xFF7C3AED); // violet-600
  static const Color primaryLight  = Color(0xFF8B5CF6); // violet-500
  static const Color accent        = Color(0xFFFBBF24); // amber-400
  static const Color accentSoft    = Color(0xFFFDE68A); // amber-200
  static const Color textPrimary   = Color(0xFFF8F8FF);
  static const Color textSecondary = Color(0xFF9090AA);
  static const Color textMuted     = Color(0xFF555570);
  static const Color success       = Color(0xFF10B981);
  static const Color error         = Color(0xFFEF4444);
  static const Color divider       = Color(0xFF1F1F30);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
