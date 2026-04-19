// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/app.dart';
import 'package:section/core/config/app_config.dart';
import 'package:section/core/localization/language_cache_helper.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/theme/theme_cubit.dart';
import 'package:section/core/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Timeago locales
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  // Notifications
  await NotificationService.init(
    backgroundHandler: _firebaseBackgroundHandler,
  );

  // Load saved preferences
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'light';
  await LanguageCacheHelper.get(); // warm cache

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..loadTheme(savedTheme)),
        BlocProvider(create: (_) => LocaleCubit()..getSavedLanguage()),
      ],
      child: const SectionApp(),
    ),
  );
}
