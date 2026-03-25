import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6C4DFF);
  static const primaryLight = Color(0xFFEDE9FF);
  static const bg = Color(0xFFFFF7ED);
  static const card = Colors.white;
  static const textDark = Color(0xFF1F2340);
  static const textLight = Color(0xFF6B7280);
  static const green = Color(0xFF22C55E);
  static const blue = Color(0xFF3B82F6);
  static const amber = Color(0xFFF59E0B);
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final poppins = GoogleFonts.poppinsTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: poppins,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textDark,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12);
        }
        return const TextStyle(color: AppColors.textLight, fontSize: 12);
      }),
    ),
    chipTheme: const ChipThemeData(selectedColor: AppColors.primaryLight),
  );
}
