// lib/core/navigation/app_routes.dart
// Route name constants - used by Navigation.offAllNamed() etc.
// The actual route builders are registered in app.dart

abstract final class AppRoutes {
  static const String splash          = '/';
  static const String language        = '/language';
  static const String onboarding      = '/onboarding';
  static const String login           = '/login';
  static const String signUp          = '/sign-up';
  static const String register        = '/register';
  static const String forgotPassword  = '/forgot-password';
  static const String completeProfile = '/complete-profile';
  static const String profileSetup    = '/profile-setup';
  static const String home            = '/home';
  static const String store           = '/store';
  static const String cart            = '/cart';
  static const String checkout        = '/checkout';
  static const String orders          = '/orders';
  static const String community       = '/community';
  static const String study           = '/study';
  static const String aiAssistant     = '/ai';
  static const String profile         = '/profile';
  static const String settings        = '/settings';
  static const String notifications   = '/notifications';
  static const String favorites       = '/favorites';
  static const String chatList        = '/chat';
}
