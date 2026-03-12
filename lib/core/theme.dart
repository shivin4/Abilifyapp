import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Accent colors similar to screenshot
  static const primary = Color(0xFF6C4DFF); // purple accents
  static const bg = Color(0xFFFFF7ED); // warm cream background
  static const card = Colors.white;
  static const textDark = Color(0xFF1F2340);
  static const textLight = Color(0xFF6B7280);
  static const green = Color(0xFF22C55E);
  static const blue = Color(0xFF3B82F6);
  static const amber = Color(0xFFF59E0B);
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final poppins = GoogleFonts.poppinsTextTheme(base.textTheme).apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: poppins.copyWith(
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textDark,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: const ChipThemeData(
      selectedColor: AppColors.primary,
    ),
  );
}
