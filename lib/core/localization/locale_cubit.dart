// lib/core/localization/locale_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<ChangeLocaleState> {
  LocaleCubit() : super(const ChangeLocaleState(locale: Locale('ar')));

  static const _supported = ['ar', 'en'];

  Future<void> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppStrings.kLanguageKey);
    emit(ChangeLocaleState(
        locale: Locale(_supported.contains(code) ? code! : 'ar')));
  }

  Future<void> changeLanguage(String code) async {
    if (!_supported.contains(code)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.kLanguageKey, code);
    emit(ChangeLocaleState(locale: Locale(code)));
  }
}
