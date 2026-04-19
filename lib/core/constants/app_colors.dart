// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Palette ─────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1565C0); // Deep Medical Blue
  static const Color primaryLight   = Color(0xFF2979FF); // Vivid Blue
  static const Color primaryDark    = Color(0xFF0D47A1); // Dark Navy Blue
  static const Color secondary      = Color(0xFF00BCD4); // Cyan Teal
  static const Color secondaryLight = Color(0xFF00E5FF); // Bright Cyan
  static const Color secondaryDark  = Color(0xFF0097A7); // Deep Teal
  static const Color accent         = Color(0xFFFF5252); // Medical Red

  // ── Light Mode ─────────────────────────────────────────────────────────────
  static const Color backgroundLight    = Color(0xFFF0F4FF);
  static const Color surfaceLight       = Color(0xFFFFFFFF);
  static const Color inputFillLight      = Color(0xFFEBF3FF);
  static const Color cardLight          = Color(0xFFFFFFFF);
  static const Color dividerLight       = Color(0xFFBBDEFB);
  static const Color textPrimaryLight   = Color(0xFF0A1929);
  static const Color textSecondaryLight = Color(0xFF546E7A);
  static const Color textHintLight      = Color(0xFF90A4AE); // hint text light mode

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF050D1A);
  static const Color surfaceDark     = Color(0xFF0D1B2E);
  static const Color cardDark        = Color(0xFF132338);
  static const Color dividerDark     = Color(0xFF1A3050);
  static const Color textPrimaryDark    = Color(0xFFE3F2FD);
  static const Color textSecondaryDark  = Color(0xFF7EA8C9);
  static const Color textHintDark       = Color(0xFF4A6080); // hint text dark mode

  // ── Aliases for older view files ───────────────────────────────────────────
  static const Color darkCard   = cardDark;
  static const Color darkBorder = dividerDark;
  static const Color grey200    = Color(0xFFEEEEEE);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF050D1A);
  static const Color darkBg     = Color(0xFF0D1117); // used in splash

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF00C853);
  static const Color warning   = Color(0xFFFFAB00);
  static const Color error     = Color(0xFFD50000);
  static const Color info      = Color(0xFF2979FF);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF050D1A), Color(0xFF1565C0), Color(0xFF00BCD4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF0D1B2E), Color(0xFF132338)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
