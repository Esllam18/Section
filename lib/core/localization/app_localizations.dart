// lib/core/localization/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Holds the localization configuration used by MaterialApp.
class AppLocalizationsSetup {
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// Backward-compatible alias so any file that still imports
/// `AppLocalizations` keeps compiling without changes.
typedef AppLocalizations = AppLocalizationsSetup;
