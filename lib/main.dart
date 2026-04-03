// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppStrings.supabaseUrl,
    anonKey: AppStrings.supabaseAnonKey,
  );

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const SectionApp());
}

class SectionApp extends StatelessWidget {
  const SectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()..getSavedLanguage()),
        BlocProvider(create: (_) => ThemeCubit()..getSavedTheme()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) => BlocBuilder<LocaleCubit, ChangeLocaleState>(
          builder: (_, localeState) => MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            locale: localeState.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            navigatorKey: Navigation.key,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          ),
        ),
      ),
    );
  }
}
