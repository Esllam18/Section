// lib/core/helpers/onboarding_cache_helper.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

abstract final class OnboardingCacheHelper {
  static Future<bool> isOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(AppStrings.kOnboardingKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppStrings.kOnboardingKey, true);
  }
}
