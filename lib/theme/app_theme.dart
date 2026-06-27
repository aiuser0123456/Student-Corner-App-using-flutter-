import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors ported from the website's globals.css HSL theme variables
/// so the app keeps the same look and feel (teal primary, amber accent).
class AppColors {
  static const primary = Color(0xFF14B8A6); // hsl(173, 80%, 40%)
  static const primaryForeground = Colors.white;
  static const accent = Color(0xFFE8B339); // hsl(43, 90%, 60%)
  static const background = Color(0xFFF7FAFA); // hsl(200, 20%, 98%)
  static const foreground = Color(0xFF374559); // hsl(215, 25%, 27%)
  static const muted = Color(0xFFE2E6EB);
  static const mutedForeground = Color(0xFF66738C);
  static const destructive = Color(0xFFEF4444);
  static const border = Color(0xFFD3D9E0);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.destructive,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0.5,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.muted,
      ),
    );
  }
}
