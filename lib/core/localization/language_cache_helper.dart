import 'package:shared_preferences/shared_preferences.dart';
class LanguageCacheHelper {
  static const _key = 'language';
  static Future<void> save(String lang) async => (await SharedPreferences.getInstance()).setString(_key, lang);
  static Future<String?> get() async => (await SharedPreferences.getInstance()).getString(_key);
  static Future<bool> has() async => (await SharedPreferences.getInstance()).containsKey(_key);
}
