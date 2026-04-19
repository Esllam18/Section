import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDark: false));

  Future<void> loadTheme(String t) async =>
      emit(ThemeState(isDark: t == 'dark'));

  /// Load from SharedPreferences (called getSavedTheme for compatibility)
  Future<void> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('theme') ?? 'light';
    emit(ThemeState(isDark: t == 'dark'));
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = !state.isDark;
    await prefs.setString('theme', isDark ? 'dark' : 'light');
    emit(ThemeState(isDark: isDark));
  }

  /// Accepts bool (from settings switch)
  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', isDark ? 'dark' : 'light');
    emit(ThemeState(isDark: isDark));
  }

  /// Accepts ThemeMode (from language selection view)
  Future<void> setThemeMode(ThemeMode mode) async {
    await setTheme(mode == ThemeMode.dark);
  }
}
