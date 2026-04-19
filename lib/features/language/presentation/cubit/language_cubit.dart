import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState(lang: 'ar', theme: ThemeMode.light));
  void selectLang(String code)   => emit(state.copyWith(lang: code));
  void selectTheme(ThemeMode m)  => emit(state.copyWith(theme: m));
}
