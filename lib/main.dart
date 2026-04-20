// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/navigation/app_route_map.dart';
import 'package:section/core/theme/theme_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart'; // AppLocalizationsSetup
import 'core/localization/locale_cubit.dart';
import 'core/navigation/app_routes.dart'; // route name constants only
import 'core/services/navigation/navigation_service.dart'; // NavigationService.navigatorKey
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppStrings.supabaseUrl,
    anonKey: AppStrings.supabaseAnonKey,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        // Only rebuild MaterialApp when dark/light actually changes
        buildWhen: (prev, curr) => prev.isDark != curr.isDark,
        builder: (_, themeState) {
          // Sync status-bar icon brightness with current theme
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeState.isDark ? Brightness.light : Brightness.dark,
          ));

          return BlocBuilder<LocaleCubit, LocaleState>(
            // Only rebuild MaterialApp when locale actually changes
            buildWhen: (prev, curr) => prev.locale != curr.locale,
            builder: (_, localeState) => MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
              locale: localeState.locale,

              // ✅ FIX 1: use AppLocalizationsSetup (actual class name)
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              localizationsDelegates:
                  AppLocalizationsSetup.localizationsDelegates,

              // ✅ FIX 2: key lives on NavigationService, not Navigation
              navigatorKey: NavigationService.navigatorKey,

              // ✅ FIX 3: AppRoutes has only string constants, no routes map.
              //    Routes map is defined in AppRouteMap (new file below).
              initialRoute: AppRoutes.home,
              routes: AppRouteMap.routes,

              builder: (context, child) {
                // Clamp device text scale between 0.9× and 1.15×
                final clampedScale = MediaQuery.of(context)
                    .textScaler
                    .scale(1.0)
                    .clamp(0.9, 1.15);
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(clampedScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
