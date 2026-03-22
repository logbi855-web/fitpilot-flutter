import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens (from CSS variables) ──────────────────────────────────────

/// Monospace text style — mirrors `font-family: 'Space Mono', monospace` used
/// in the original CSS for badges, plan tags, and intensity labels.
class AppTextStyles {
  static TextStyle mono({
    double fontSize = 11,
    Color color = AppColors.muted,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.spaceMono(
          fontSize: fontSize, color: color, fontWeight: fontWeight);
}

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF111118);
  static const card = Color(0xFF16161F);
  static const card2 = Color(0xFF1E1E2A);
  static const border = Color(0xFF252535);
  static const border2 = Color(0xFF2E2E42);
  static const text = Color(0xFFE8E8F0);
  static const muted = Color(0xFF9CA3AF);
  static const muted2 = Color(0xFF4B5563);
  static const primary = Color(0xFFA78BFA);   // --lime (accent purple)
  static const primaryDim = Color(0xFF7C3AED); // --lime-dim
  static const error = Color(0xFFFF5C5C);
  static const blue = Color(0xFF818CF8);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDim,
        onSurface: AppColors.text,
        error: AppColors.error,
        outline: AppColors.border,
      ),
      cardTheme: const CardThemeData(color: AppColors.card),
      dividerColor: AppColors.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        toolbarHeight: 56,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryDim,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.syne(fontSize: 11, color: AppColors.text),
        ),
      ),
      textTheme: GoogleFonts.syneTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.syne(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card2,
        labelStyle: GoogleFonts.syne(color: AppColors.text, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}
