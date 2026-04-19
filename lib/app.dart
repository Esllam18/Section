// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/localization/app_localizations.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation_service.dart';
import 'package:section/core/theme/app_theme.dart';
import 'package:section/core/theme/theme_cubit.dart';
import 'package:section/core/theme/theme_state.dart';
import 'package:section/features/splash/presentation/splash_screen.dart';
import 'package:section/features/language/presentation/language_selection_screen.dart';
import 'package:section/features/onboarding/presentation/onboarding_screen.dart';
import 'package:section/features/auth/presentation/screens/login_screen.dart';
import 'package:section/features/auth/presentation/screens/register_screen.dart';
import 'package:section/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:section/features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'package:section/layout/main_layout.dart';

class SectionApp extends StatelessWidget {
  const SectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (_, themeState) => BlocBuilder<LocaleCubit, LocaleState>(
        builder: (_, localeState) => MaterialApp(
          title: 'Section',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: localeState.locale,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: const SplashScreen(),
          routes: {
            '/':               (_) => const SplashScreen(),
            '/language':       (_) => const LanguageSelectionScreen(),
            '/onboarding':     (_) => const OnboardingScreen(),
            '/login':          (_) => const LoginScreen(),
            '/register':       (_) => const RegisterScreen(),
            '/sign-up':        (_) => const RegisterScreen(),
            '/forgot-password':(_) => const ForgotPasswordScreen(),
            '/profile-setup':  (_) => const ProfileSetupScreen(),
            '/complete-profile':(_) => const ProfileSetupScreen(),
            '/home':           (_) => const MainLayout(),
          },
        ),
      ),
    );
  }
}
