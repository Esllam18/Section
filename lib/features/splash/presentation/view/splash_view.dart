// lib/features/splash/presentation/view/splash_view.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/helpers/language_cache_helper.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../widgets/splash_bg.dart';
import '../widgets/splash_logo_content.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _ctrl.forward();
    _doNavigate();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _doNavigate() async {
    await Future.delayed(AppDurations.splash);
    if (!mounted) return;
    Navigation.offAllNamed(await _resolve());
  }

  Future<String> _resolve() async {
    if (!await LanguageCacheHelper.isLanguageSelected()) return AppRoutes.language;
    if (!await OnboardingCacheHelper.isOnboardingSeen()) return AppRoutes.onboarding;
    if (Supabase.instance.client.auth.currentSession != null) return AppRoutes.home;
    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0D1117),
    body: Stack(fit: StackFit.expand, children: [
      const SplashBg(),
      // Dark vignette
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0x4D0D1117), Color(0x800D1117), Color(0xCC0D1117)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter))),
      FadeTransition(opacity: _fadeIn, child: const SplashLogoContent()),
    ]),
  );
}
