// lib/features/language/presentation/view/language_selection_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/section_logo.dart';
import '../cubit/language_cubit.dart';
import '../widgets/lang_card.dart';
import '../widgets/theme_picker.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LanguageCubit(),
    child: const _Body(),
  );
}

class _Body extends StatelessWidget {
  const _Body();

  Future<void> _onContinue(BuildContext context, LanguageState st) async {
    await context.read<LocaleCubit>().changeLanguage(st.lang);
    await context.read<ThemeCubit>().setThemeMode(st.theme);
    if (!context.mounted) return;
    final seen = await OnboardingCacheHelper.isOnboardingSeen();
    Navigation.offAllNamed(seen ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(builder: (ctx, st) {
      final isAR = st.lang == 'ar';
      final theme = Theme.of(ctx);

      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSym(h: 24, v: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              Gap(ctx.h(0.025)),

              // Logo
              AppAnimations.fadeScale(duration: AppDurations.slow, beginScale: 0.5,
                child: Center(child: SectionLogo(size: 68,
                  bgColor: theme.colorScheme.primary.withOpacity(0.1),
                  crossColor: theme.colorScheme.primary))),

              const Gap(22),

              // Title — dynamically language-aware
              AppAnimations.fadeSlide(duration: AppDurations.slow,
                delay: const Duration(milliseconds: 100), dir: SlideDir.up, dist: 18,
                child: Text(isAR ? 'اختر لغتك' : 'Choose Your Language',
                  style: theme.textTheme.headlineMedium, textAlign: TextAlign.center)),

              const Gap(8),

              AppAnimations.fade(duration: AppDurations.slow, delay: const Duration(milliseconds: 150),
                child: Text(isAR ? 'ستُطبَّق على كامل التطبيق' : 'This will apply across the entire app',
                  style: theme.textTheme.bodySmall, textAlign: TextAlign.center)),

              Gap(ctx.r(28)),

              // Language cards
              AppAnimations.fadeSlide(duration: AppDurations.slow,
                delay: const Duration(milliseconds: 180), dir: SlideDir.up, dist: 22,
                child: Column(children: [
                  LangCard(code: 'ar', native: 'العربية', label: 'Arabic',
                    emoji: '🇪🇬', selected: st.lang == 'ar',
                    onTap: () => ctx.read<LanguageCubit>().selectLang('ar')),
                  const Gap(12),
                  LangCard(code: 'en', native: 'English', label: 'الإنجليزية',
                    emoji: '🇺🇸', selected: st.lang == 'en',
                    onTap: () => ctx.read<LanguageCubit>().selectLang('en')),
                ])),

              Gap(ctx.r(24)),

              // Divider with label
              AppAnimations.fade(duration: AppDurations.slow, delay: const Duration(milliseconds: 260),
                child: Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(isAR ? 'المظهر' : 'Appearance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45)))),
                  const Expanded(child: Divider()),
                ])),

              const Gap(16),

              // Theme picker
              AppAnimations.fadeSlide(duration: AppDurations.slow,
                delay: const Duration(milliseconds: 320), dir: SlideDir.up, dist: 16,
                child: ThemePicker(selected: st.theme, isAR: isAR,
                  onChange: (m) => ctx.read<LanguageCubit>().selectTheme(m))),

              Gap(ctx.r(36)),

              // Continue button — label changes with lang
              AppAnimations.fadeSlide(duration: AppDurations.slow,
                delay: const Duration(milliseconds: 400), dir: SlideDir.up, dist: 14,
                child: CustomButton(
                  label: isAR ? 'متابعة' : 'Continue',
                  onTap: () => _onContinue(ctx, st),
                  trailing: Icon(isAR ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18))),

              const Gap(16),
            ]),
          ),
        ),
      );
    });
  }
}
