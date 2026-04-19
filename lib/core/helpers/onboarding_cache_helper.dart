// lib/core/helpers/onboarding_cache_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

abstract final class OnboardingCacheHelper {
  static Future<bool> isOnboardingSeen() async =>
      (await SharedPreferences.getInstance()).getBool(AppStrings.kOnboarding) ?? false;
  static Future<void> markOnboardingSeen() async =>
      (await SharedPreferences.getInstance()).setBool(AppStrings.kOnboarding, true);
}
