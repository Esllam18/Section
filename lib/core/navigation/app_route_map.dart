// lib/core/navigation/app_route_map.dart
//
// Centralises the MaterialApp `routes:` map so that:
//   • AppRoutes stays a pure string-constants class (no widget imports)
//   • main.dart has one clean import instead of importing every screen
//
// HOW TO ADD A NEW ROUTE
// ──────────────────────
// 1. Add the route string constant to AppRoutes (app_routes.dart).
// 2. Import the screen widget below.
// 3. Add the entry to the `routes` map.

import 'package:flutter/material.dart';
import 'package:section/core/navigation/app_routes.dart';
import 'package:section/features/splash/presentation/splash_screen.dart';

// ── Screens ──────────────────────────────────────────────────────────────────
// Replace each import with the real path once screens are created.
// Placeholder screens are provided so the project compiles immediately.
// import 'package:section/features/language/language_screen.dart';
// import 'package:section/features/onboarding/onboarding_screen.dart';
// import 'package:section/features/auth/login/login_screen.dart';
// import 'package:section/features/auth/signup/sign_up_screen.dart';
// import 'package:section/features/auth/register/register_screen.dart';
// import 'package:section/features/auth/forgot_password/forgot_password_screen.dart';
// import 'package:section/features/auth/complete_profile/complete_profile_screen.dart';
// import 'package:section/features/auth/profile_setup/profile_setup_screen.dart';
// import 'package:section/features/home/home_screen.dart';
// import 'package:section/features/store/store_screen.dart';
// import 'package:section/features/cart/cart_screen.dart';
// import 'package:section/features/checkout/checkout_screen.dart';
// import 'package:section/features/orders/orders_screen.dart';
// import 'package:section/features/community/community_screen.dart';
// import 'package:section/features/study/study_screen.dart';
// import 'package:section/features/ai_assistant/ai_assistant_screen.dart';
// import 'package:section/features/profile/profile_screen.dart';
// import 'package:section/features/settings/settings_screen.dart';
// import 'package:section/features/notifications/notifications_screen.dart';
// import 'package:section/features/favorites/favorites_screen.dart';
// import 'package:section/features/chat/chat_list_screen.dart';

abstract final class AppRouteMap {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashScreen(),
        // Uncomment each line as the corresponding screen is built:
        // AppRoutes.language:        (_) => const LanguageScreen(),
        // AppRoutes.onboarding:      (_) => const OnboardingScreen(),
        // AppRoutes.login:           (_) => const LoginScreen(),
        // AppRoutes.signUp:          (_) => const SignUpScreen(),
        // AppRoutes.register:        (_) => const RegisterScreen(),
        // AppRoutes.forgotPassword:  (_) => const ForgotPasswordScreen(),
        // AppRoutes.completeProfile: (_) => const CompleteProfileScreen(),
        // AppRoutes.profileSetup:    (_) => const ProfileSetupScreen(),
        // AppRoutes.home:            (_) => const HomeScreen(),
        // AppRoutes.store:           (_) => const StoreScreen(),
        // AppRoutes.cart:            (_) => const CartScreen(),
        // AppRoutes.checkout:        (_) => const CheckoutScreen(),
        // AppRoutes.orders:          (_) => const OrdersScreen(),
        // AppRoutes.community:       (_) => const CommunityScreen(),
        // AppRoutes.study:           (_) => const StudyScreen(),
        // AppRoutes.aiAssistant:     (_) => const AiAssistantScreen(),
        // AppRoutes.profile:         (_) => const ProfileScreen(),
        // AppRoutes.settings:        (_) => const SettingsScreen(),
        // AppRoutes.notifications:   (_) => const NotificationsScreen(),
        // AppRoutes.favorites:       (_) => const FavoritesScreen(),
        // AppRoutes.chatList:        (_) => const ChatListScreen(),
      };
}
