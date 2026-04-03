// lib/features/splash/presentation/view/splash_view.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/language_cache_helper.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../widgets/animated_logo_widget.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(AppDurations.splashDelay);
    if (!mounted) return;
    Navigation.offAllNamed(await _resolveRoute());
  }

  Future<String> _resolveRoute() async {
    final langSelected = await LanguageCacheHelper.isLanguageSelected();
    if (!langSelected) return AppRoutes.language;

    final onboardingSeen = await OnboardingCacheHelper.isOnboardingSeen();
    if (!onboardingSeen) return AppRoutes.onboarding;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) return AppRoutes.home;

    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              AppAnimations.combined(
                type: CombineType.fadeScale,
                duration: AppDurations.short,
                curve: Curves.elasticOut,
                beginScale: 0.3,
                child: const AnimatedLogoWidget(),
              ),
              const SizedBox(height: 32),
              AppAnimations.combined(
                type: CombineType.fadeSlide,
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 300),
                direction: SlideDirection.up,
                slideDistance: 20,
                child: const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppAnimations.fade(
                duration: AppDurations.medium,
                delay: const Duration(milliseconds: 500),
                child: Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withValues(alpha: 0.8),
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              AppAnimations.fade(
                duration: AppDurations.short,
                delay: const Duration(milliseconds: 800),
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
