import 'package:flutter/material.dart';

/// Token warna disamakan dengan portal web peserta
/// (WorkshopFTIPPSI/frontend/src/pages/peserta/peserta.css & workshopStates.css).
class AppColors {
  AppColors._();
  // --peserta-green / --peserta-accent / --peserta-tint
  static const primary = Color(0xFF14532D);
  static const primaryHover = Color(0xFF0E4725);
  static const green = Color(0xFF228B45);
  static const paleGreen = Color(0xFFEDF7EF);
  static const statusGreen = Color(0xFF176336);
  // Latar & teks
  static const background = Color(0xFFF7F8FA);
  static const text = Color(0xFF263238);
  static const heading = Color(0xFF14271C);
  // --peserta-muted / --peserta-line
  static const muted = Color(0xFF66736C);
  static const border = Color(0xFFDFE6E1);
  static const inputBorder = Color(0xFFD5DDD8);
  static const secondaryBorder = Color(0xFFB9CEC0);
  // Nada status (.peserta-status--amber/red/blue/gray)
  static const amber = Color(0xFF946515);
  static const amberBg = Color(0xFFFFF7E5);
  static const red = Color(0xFFA82E32);
  static const redBg = Color(0xFFFFF0EF);
  static const blue = Color(0xFF246580);
  static const blueBg = Color(0xFFEAF4FA);
  static const gray = Color(0xFF66736C);
  static const grayBg = Color(0xFFF0F2F1);
  // .peserta-info
  static const info = Color(0xFF236483);
  static const infoBg = Color(0xFFEDF5FA);
}

class AppTheme {
  AppTheme._();
  static const fontFamily = 'PlusJakartaSans';
  static const unandGreen = AppColors.primary;
  static const unandGreenLight = AppColors.green;
  static const unandGold = Color(0xFFF4B400);

  /// Sudut membulat seragam seperti web (border-radius: 8px)
  static const radius = 8.0;

  /// Bayangan kartu web: 0 4px 16px #1a36230d
  static const cardShadow = [
    BoxShadow(color: Color(0x0D1A3623), offset: Offset(0, 4), blurRadius: 16)
  ];

  /// Bayangan tombol utama web: 0 3px 9px #14532d24
  static const buttonShadow = [
    BoxShadow(color: Color(0x2414532D), offset: Offset(0, 3), blurRadius: 9)
  ];

  static OutlineInputBorder _input(Color color, [double width = 1]) =>
      OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width));

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.green,
            error: AppColors.red,
            surface: Colors.white),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColors.heading),
          headlineSmall: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
              color: AppColors.heading),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.heading),
          titleMedium: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
          bodyLarge:
              TextStyle(fontSize: 14, height: 1.55, color: AppColors.text),
          bodyMedium:
              TextStyle(fontSize: 12, height: 1.5, color: AppColors.text),
          bodySmall:
              TextStyle(fontSize: 11, height: 1.5, color: AppColors.muted),
        ),
        // Topbar web: putih, garis bawah, judul tebal
        appBarTheme: const AppBarTheme(
            centerTitle: false,
            toolbarHeight: 64,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
                fontFamily: fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.heading),
            shape: Border(bottom: BorderSide(color: AppColors.border))),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withAlpha(115),
                disabledForegroundColor: Colors.white,
                minimumSize: const Size(0, 46),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                textStyle: const TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius)))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: Colors.white,
                minimumSize: const Size(0, 46),
                side: const BorderSide(color: AppColors.secondaryBorder),
                textStyle: const TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius)))),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600))),
        chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius))),
        checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : Colors.transparent),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF87918C)),
            prefixIconColor: const Color(0xFF87918C),
            suffixIconColor: AppColors.muted,
            border: _input(AppColors.inputBorder),
            enabledBorder: _input(AppColors.inputBorder),
            disabledBorder: _input(AppColors.border),
            focusedBorder: _input(AppColors.green, 2),
            errorBorder: _input(AppColors.red),
            focusedErrorBorder: _input(AppColors.red, 2),
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.red)),
        dividerTheme: const DividerThemeData(
            color: AppColors.border, thickness: 1, space: 1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.green, linearTrackColor: Color(0xFFE6EDE8)),
        dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius))),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent),
        // Toast web: latar #f2fcf4, garis #b9cec0, teks hijau
        snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            contentTextStyle: const TextStyle(
                fontFamily: fontFamily, fontSize: 13, color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius))),
      );
}
