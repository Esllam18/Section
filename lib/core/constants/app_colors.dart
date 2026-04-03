// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6FBF);
  static const Color primaryLight = Color(0xFF4D9FE0);
  static const Color primaryDark = Color(0xFF0D4A87);

  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF5DF2D6);
  static const Color accentDark = Color(0xFF008C78);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0A);

  static const Color grey50  = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error        = Color(0xFFC62828);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color warning      = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFFDE7);
  static const Color info         = Color(0xFF01579B);
  static const Color infoLight    = Color(0xFFE1F5FE);

  // ── Dark surfaces ─────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface    = Color(0xFF1A1D27);
  static const Color darkCard       = Color(0xFF22263A);
  static const Color darkBorder     = Color(0xFF2E3348);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D4A87), Color(0xFF1A6FBF), Color(0xFF00BFA5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
