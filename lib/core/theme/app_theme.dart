// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  static TextTheme _textTheme(Color base) => GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: base),
          displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: base),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: base),
          headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: base),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: base),
          titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: base),
          titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: base),
          titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: base),
          bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: base),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: base),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: base.withValues(alpha: 0.65)),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: base),
          labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: base),
          labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: base.withValues(alpha: 0.65)),
        ),
      );

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentLight,
          surface: AppColors.white,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.grey900,
          onError: AppColors.white,
        ),
        scaffoldBg: AppColors.grey50,
        cardBg: AppColors.white,
        cardBorder: AppColors.grey200,
        inputFill: AppColors.grey100,
        inputBorder: AppColors.grey200,
        hintColor: AppColors.grey500,
        textBase: AppColors.grey900,
        statusBarBrightness: Brightness.dark,
      );

  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          primaryContainer: AppColors.primary,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentDark,
          surface: AppColors.darkSurface,
          error: Color(0xFFEF9A9A),
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: Color(0xFFE8EAF0),
          onError: AppColors.black,
        ),
        scaffoldBg: AppColors.darkBackground,
        cardBg: AppColors.darkCard,
        cardBorder: AppColors.darkBorder,
        inputFill: AppColors.darkCard,
        inputBorder: AppColors.darkBorder,
        hintColor: AppColors.grey600,
        textBase: const Color(0xFFE8EAF0),
        statusBarBrightness: Brightness.light,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color cardBg,
    required Color cardBorder,
    required Color inputFill,
    required Color inputBorder,
    required Color hintColor,
    required Color textBase,
    required Brightness statusBarBrightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: _textTheme(textBase),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.white : AppColors.darkSurface,
        foregroundColor: textBase,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textBase,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: hintColor),
        errorStyle: GoogleFonts.cairo(fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: cardBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: brightness == Brightness.light ? AppColors.white : AppColors.darkSurface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: brightness == Brightness.light ? AppColors.grey400 : AppColors.grey600,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
