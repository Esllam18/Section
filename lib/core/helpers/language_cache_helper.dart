// lib/core/helpers/language_cache_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

abstract final class LanguageCacheHelper {
  static Future<void> setLanguage(String code) async =>
      (await SharedPreferences.getInstance()).setString(AppStrings.kLanguage, code);
  static Future<String?> getLanguage() async =>
      (await SharedPreferences.getInstance()).getString(AppStrings.kLanguage);
  static Future<bool> isLanguageSelected() async {
    final s = (await SharedPreferences.getInstance()).getString(AppStrings.kLanguage);
    return s != null && s.isNotEmpty;
  }
}
