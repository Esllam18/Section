// lib/features/splash/presentation/widgets/splash_logo_content.dart
import 'package:flutter/material.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_logo.dart';

class SplashLogoContent extends StatelessWidget {
  const SplashLogoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Spacer(flex: 5),

      AppAnimations.fadeScale(duration: AppDurations.slow,
        delay: const Duration(milliseconds: 200),
        beginScale: 0.4,
        child: const SectionLogo(size: 100)),

      const SizedBox(height: 30),

      AppAnimations.fadeSlide(duration: AppDurations.slow,
        delay: const Duration(milliseconds: 450), dir: SlideDir.up, dist: 20,
        child: const Text(AppStrings.appName, style: TextStyle(
          fontSize: 46, fontWeight: FontWeight.w800,
          color: AppColors.white, letterSpacing: 10, height: 1))),

      const SizedBox(height: 16),

      AppAnimations.fade(duration: AppDurations.slow,
        delay: const Duration(milliseconds: 700),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(), const SizedBox(width: 10),
          Text(AppStrings.appTagline, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.white.withOpacity(0.60), letterSpacing: 3.5)),
          const SizedBox(width: 10), _dot(),
        ])),

      const Spacer(flex: 5),

      AppAnimations.fade(duration: AppDurations.slow,
        delay: const Duration(milliseconds: 1000),
        child: Column(children: [
          SizedBox(width: 26, height: 26,
            child: CircularProgressIndicator(strokeWidth: 1.8,
              color: AppColors.white.withOpacity(0.6),
              strokeCap: StrokeCap.round)),
          const SizedBox(height: 14),
          Text('v1.0.0', style: TextStyle(fontSize: 11,
            color: AppColors.white.withOpacity(0.28), letterSpacing: 1.5)),
        ])),

      const SizedBox(height: 52),
    ]);
  }

  Widget _dot() => Container(width: 4, height: 4,
      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.85), shape: BoxShape.circle));
}
