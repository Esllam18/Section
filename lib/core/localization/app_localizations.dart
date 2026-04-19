import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class AppLocalizationsSetup {
  static const supportedLocales = [Locale('ar'), Locale('en')];
  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
