// lib/features/splash/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:section/core/constants/app_assets.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_text_styles.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/auth/presentation/screens/login_screen.dart';
import 'package:section/features/language/presentation/language_selection_screen.dart';
import 'package:section/features/onboarding/presentation/onboarding_screen.dart';
import 'package:section/features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'package:section/layout/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLang = prefs.containsKey('language');
    final hasOnboarding = prefs.getBool('onboarding_seen') ?? false;
    final session = SupabaseService.auth.currentSession;

    if (!hasLang) { Navigation.offAll(const LanguageSelectionScreen()); return; }
    if (!hasOnboarding) { Navigation.offAll(const OnboardingScreen()); return; }
    if (session == null) { Navigation.offAll(const LoginScreen()); return; }

    try {
      final p = await SupabaseService.client
          .from('profiles').select('is_profile_complete').eq('id', session.user.id).maybeSingle();
      if (p?['is_profile_complete'] == true) {
        Navigation.offAll(const MainLayout());
      } else {
        Navigation.offAll(const ProfileSetupScreen());
      }
    } catch (_) {
      Navigation.offAll(const LoginScreen());
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 10))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: SvgPicture.asset(AppAssets.logoSvg, width: 110, height: 110),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // App name
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text('Section', style: AppTextStyles.appName),
                ),
                const SizedBox(height: 10),
                // Tagline slide-up
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(children: [
                      Text(
                        'YOUR MEDICAL ECOSYSTEM',
                        style: AppTextStyles.tagline.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'منصتك الطبية الشاملة',
                        style: AppTextStyles.tagline.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Cairo', letterSpacing: 0,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 60),
                // Loading dots
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _LoadingDots(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final t = (_c.value - delay).clamp(0.0, 1.0);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
