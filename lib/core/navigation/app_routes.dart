// lib/core/navigation/app_routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/view/forgot_password_view.dart';
import '../../features/auth/presentation/view/login_view.dart';
import '../../features/auth/presentation/view/sign_up_view.dart';
import '../../features/complete_profile/presentation/cubit/complete_profile_cubit.dart';
import '../../features/complete_profile/presentation/view/complete_profile_view.dart';
import '../../features/home/presentation/view/home_view.dart';
import '../../features/language/presentation/view/language_selection_view.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/onboarding/presentation/view/onboarding_view.dart';
import '../../features/splash/presentation/view/splash_view.dart';

abstract final class AppRoutes {
  static const String splash          = '/';
  static const String language        = '/language';
  static const String onboarding      = '/onboarding';
  static const String login           = '/login';
  static const String signUp          = '/sign-up';
  static const String forgotPassword  = '/forgot-password';
  static const String completeProfile = '/complete-profile';
  static const String home            = '/home';

  static Map<String, WidgetBuilder> get routes => {
        splash:     (_) => const SplashView(),
        language:   (_) => const LanguageSelectionView(),
        onboarding: (_) => BlocProvider(
              create: (_) => OnboardingCubit(),
              child: const OnboardingView(),
            ),
        login:      (_) => BlocProvider(
              create: (_) => AuthCubit(),
              child: const LoginView(),
            ),
        signUp:     (_) => BlocProvider(
              create: (_) => AuthCubit(),
              child: const SignUpView(),
            ),
        forgotPassword: (_) => BlocProvider(
              create: (_) => AuthCubit(),
              child: const ForgotPasswordView(),
            ),
        completeProfile: (_) => BlocProvider(
              create: (_) => CompleteProfileCubit(),
              child: const CompleteProfileView(),
            ),
        home: (_) => const HomeView(),
      };
}
