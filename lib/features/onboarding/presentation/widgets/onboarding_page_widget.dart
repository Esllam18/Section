// lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extension.dart';

class OnboardingPageWidget extends StatelessWidget {
  final int index;
  const OnboardingPageWidget({super.key, required this.index});

  static const _data = [
    _OData(
      titleKey: 'onboarding_1_title',
      subtitleKey: 'onboarding_1_subtitle',
      localAsset: 'assets/lottie/onboarding_1.json',
      fallbackIcon: Icons.medical_services_rounded,
    ),
    _OData(
      titleKey: 'onboarding_2_title',
      subtitleKey: 'onboarding_2_subtitle',
      localAsset: 'assets/lottie/onboarding_2.json',
      fallbackIcon: Icons.menu_book_rounded,
    ),
    _OData(
      titleKey: 'onboarding_3_title',
      subtitleKey: 'onboarding_3_subtitle',
      localAsset: 'assets/lottie/onboarding_3.json',
      fallbackIcon: Icons.smart_toy_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = _data[index];

    return Padding(
      padding: context.rSymmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppAnimations.combined(
            type: CombineType.fadeScale,
            duration: AppDurations.short,
            beginScale: 0.7,
            child: SizedBox(
              height: context.h(0.34),
              child: Lottie.asset(
                d.localAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  d.fallbackIcon,
                  size: 120,
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          SizedBox(height: context.r(32)),
          AppAnimations.combined(
            type: CombineType.fadeSlide,
            duration: AppDurations.short,
            delay: const Duration(milliseconds: 150),
            direction: SlideDirection.up,
            slideDistance: 20,
            child: Text(
              d.titleKey.tr(context),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: context.r(14)),
          AppAnimations.fade(
            duration: AppDurations.short,
            delay: const Duration(milliseconds: 300),
            child: Text(
              d.subtitleKey.tr(context),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OData {
  final String titleKey, subtitleKey, localAsset;
  final IconData fallbackIcon;
  const _OData({
    required this.titleKey,
    required this.subtitleKey,
    required this.localAsset,
    required this.fallbackIcon,
  });
}
