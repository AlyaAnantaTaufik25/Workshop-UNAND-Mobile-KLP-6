import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const primary = Color(0xFF14532D);
  static const green = Color(0xFF228B45);
  static const paleGreen = Color(0xFFEDF7EF);
  static const background = Color(0xFFF7F8FA);
  static const text = Color(0xFF263238);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE5E7EB);
  static const amber = Color(0xFFA16207);
  static const red = Color(0xFFB91C1C);
}

class AppTheme {
  AppTheme._();
  static const unandGreen = AppColors.primary;
  static const unandGreenLight = AppColors.green;
  static const unandGold = Color(0xFFF4B400);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.green,
            surface: Colors.white),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
              color: AppColors.text),
          headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
              color: AppColors.text),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
          titleMedium: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
          bodyLarge:
              TextStyle(fontSize: 14, height: 1.55, color: AppColors.text),
          bodyMedium:
              TextStyle(fontSize: 12, height: 1.5, color: AppColors.text),
          bodySmall:
              TextStyle(fontSize: 10, height: 1.5, color: AppColors.muted),
        ),
        appBarTheme: const AppBarTheme(
            centerTitle: true,
            toolbarHeight: 64,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
            shape: Border(bottom: BorderSide(color: AppColors.border))),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: Color(0xFFD8E7DC)),
                textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)))),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIconColor: const Color(0xFF94A3B8),
            suffixIconColor: AppColors.muted,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFDBE0E6))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFDBE0E6))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.green, width: 1.5))),
        dividerTheme: const DividerThemeData(
            color: AppColors.border, thickness: 1, space: 1),
        snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11))),
      );
}
