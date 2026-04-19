part of 'language_cubit.dart';
class LanguageState {
  final String lang;
  final ThemeMode theme;
  const LanguageState({required this.lang, required this.theme});
  LanguageState copyWith({String? lang, ThemeMode? theme}) =>
      LanguageState(lang: lang ?? this.lang, theme: theme ?? this.theme);
}
