import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_cache_helper.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(locale: Locale('ar')));

  bool get isArabic => state.locale.languageCode == 'ar';

  Future<void> getSavedLanguage() async {
    final lang = await LanguageCacheHelper.get();
    emit(LocaleState(locale: Locale(lang ?? 'ar')));
  }

  Future<void> changeLanguage(String lang) async {
    await LanguageCacheHelper.save(lang);
    emit(LocaleState(locale: Locale(lang)));
  }
}
