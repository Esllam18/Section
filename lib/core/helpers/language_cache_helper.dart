// lib/core/helpers/language_cache_helper.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

abstract final class LanguageCacheHelper {
  static Future<void> setLanguage(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppStrings.kLanguageKey, code);
  }

  static Future<String?> getLanguage() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(AppStrings.kLanguageKey);
  }

  static Future<bool> isLanguageSelected() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(AppStrings.kLanguageKey);
    return s != null && s.isNotEmpty;
  }
}
