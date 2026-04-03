// lib/features/language/presentation/view/language_selection_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/language_card_widget.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});
  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  String _selected = 'ar';

  Future<void> _onContinue() async {
    await context.read<LocaleCubit>().changeLanguage(_selected);
    if (!mounted) return;
    final seen = await OnboardingCacheHelper.isOnboardingSeen();
    Navigation.offAllNamed(seen ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: context.rSymmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),
              AppAnimations.combined(
                type: CombineType.fadeScale,
                duration: AppDurations.short,
                beginScale: 0.5,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.language_rounded,
                      size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),
              AppAnimations.combined(
                type: CombineType.fadeSlide,
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 150),
                direction: SlideDirection.up,
                slideDistance: 20,
                child: Text('select_language'.tr(context),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 10),
              AppAnimations.fade(
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 250),
                child: Text(
                  'select_language_subtitle'.tr(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              AppAnimations.combined(
                type: CombineType.fadeSlide,
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 350),
                direction: SlideDirection.up,
                slideDistance: 30,
                child: Column(children: [
                  LanguageCardWidget(
                    code: 'ar', label: 'Arabic', nativeLabel: 'العربية',
                    flagEmoji: '🇪🇬', isSelected: _selected == 'ar',
                    onTap: () => setState(() => _selected = 'ar'),
                  ),
                  const SizedBox(height: 14),
                  LanguageCardWidget(
                    code: 'en', label: 'English', nativeLabel: 'English',
                    flagEmoji: '🇬🇧', isSelected: _selected == 'en',
                    onTap: () => setState(() => _selected = 'en'),
                  ),
                ]),
              ),
              const Spacer(),
              AppAnimations.combined(
                type: CombineType.fadeSlide,
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 500),
                direction: SlideDirection.up,
                slideDistance: 20,
                child: CustomButton(
                    label: 'continue'.tr(context), onTap: _onContinue),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
