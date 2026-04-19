// lib/core/constants/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Lora — Brand/Headings ─────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 32,
    color: AppColors.textPrimaryLight, height: 1.2,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 26,
    color: AppColors.textPrimaryLight,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22,
    color: AppColors.textPrimaryLight,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 18,
    color: AppColors.textPrimaryLight,
  );
  static const TextStyle appName = TextStyle(
    fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 34,
    color: AppColors.white, letterSpacing: 1.5,
  );
  static const TextStyle tagline = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 13,
    color: AppColors.white, letterSpacing: 2.0,
  );

  // ── Cairo — Body ──────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 16,
    color: AppColors.textPrimaryLight, height: 1.6,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 14,
    color: AppColors.textPrimaryLight, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 12,
    color: AppColors.textSecondaryLight,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16,
    color: AppColors.textPrimaryLight,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14,
    color: AppColors.textPrimaryLight,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 12,
    color: AppColors.textSecondaryLight,
  );
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16,
    color: AppColors.white,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 11,
    color: AppColors.textSecondaryLight,
  );
}
