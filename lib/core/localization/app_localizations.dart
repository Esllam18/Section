// lib/core/localization/app_localizations.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale? locale;
  AppLocalizations({this.locale});

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _Delegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  late Map<String, String> _strings;

  Future<void> _load() async {
    final raw = await rootBundle
        .loadString('assets/lang/${locale!.languageCode}.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    _strings = map.map((k, v) => MapEntry(k, v.toString()));
  }

  String translate(String key) {
    final v = _strings[key];
    if (v != null && v.trim().isNotEmpty) return v;
    final norm = _n(key);
    for (final e in _strings.entries) {
      if (_n(e.key) == norm && e.value.trim().isNotEmpty) return e.value;
    }
    return key;
  }

  String translateArgs(String key, [Map<String, Object?> args = const {}]) {
    var v = translate(key);
    args.forEach((k, val) => v = v.replaceAll('{$k}', '${val ?? ''}'));
    return v;
  }

  String _n(String s) =>
      s.replaceAll(RegExp(r'[_\s-]'), '').toLowerCase().trim();
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale l) => ['en', 'ar'].contains(l.languageCode);
  @override
  Future<AppLocalizations> load(Locale l) async {
    final loc = AppLocalizations(locale: l);
    await loc._load();
    return loc;
  }
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> o) =>
      false;
}

extension TrX on String {
  String tr(BuildContext ctx) =>
      AppLocalizations.of(ctx)?.translate(this) ?? this;
  String trArgs(BuildContext ctx, [Map<String, Object?> args = const {}]) =>
      AppLocalizations.of(ctx)?.translateArgs(this, args) ?? this;
}
