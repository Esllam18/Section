// lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../view/onboarding_data.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OPage data;
  final bool isAR;
  const OnboardingPageWidget({super.key, required this.data, required this.isAR});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: context.rSym(h: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Lottie animation
        AppAnimations.fadeScale(duration: AppDurations.slow, beginScale: 0.65,
          child: SizedBox(height: context.h(0.32),
            child: Lottie.asset(data.localAsset, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.medical_services_rounded,
                size: 120, color: theme.colorScheme.primary.withOpacity(0.15))))),

        SizedBox(height: context.r(28)),

        // Title
        AppAnimations.fadeSlide(duration: AppDurations.slow,
          delay: const Duration(milliseconds: 120), dir: SlideDir.up, dist: 18,
          child: Text(isAR ? data.titleAr : data.titleEn,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center)),

        SizedBox(height: context.r(12)),

        // Subtitle
        AppAnimations.fade(duration: AppDurations.slow, delay: const Duration(milliseconds: 220),
          child: Text(isAR ? data.subAr : data.subEn,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.58), height: 1.65),
            textAlign: TextAlign.center)),
      ]));
  }
}
