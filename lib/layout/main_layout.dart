// lib/layout/main_layout.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:section/features/community/presentation/screens/community_screen.dart';
import 'package:section/features/home/home_screen.dart';
import 'package:section/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:section/features/profile/presentation/screens/profile_screen.dart';
import 'package:section/features/store/presentation/screens/store_screen.dart';
import 'package:section/features/study/presentation/screens/study_screen.dart';
import 'package:section/layout/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _idx = 0;
  bool _offline = false;
  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((results) {
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _offline = isOffline);
    });
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    try {
      final data = await SupabaseService.client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);
      if (mounted) setState(() => _unreadNotifs = (data as List).length);
    } catch (_) {}
  }

  final _screens = const [
    HomeScreen(),
    StoreScreen(),
    CommunityScreen(),
    StudyScreen(),
    AiAssistantScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          body: Column(children: [
            // Offline banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: _offline ? 48 : 0,
              color: AppColors.warning,
              child: _offline ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(isAr ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection',
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ]) : const SizedBox.shrink(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(key: ValueKey(_idx), child: _screens[_idx]),
              ),
            ),
          ]),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _idx,
            isAr: isAr,
            unreadNotifs: _unreadNotifs,
            onTap: (i) {
              setState(() => _idx = i);
              if (i == 5) _loadUnreadCount(); // refresh when going to profile
            },
          ),
          floatingActionButton: _idx == 0
              ? FloatingActionButton(
                  mini: true,
                  onPressed: () => Navigation.to(const NotificationsScreen()),
                  backgroundColor: AppColors.secondary,
                  child: Stack(children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    if (_unreadNotifs > 0)
                      Positioned(top: 0, right: 0,
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        )),
                  ]),
                )
              : null,
        );
      },
    );
  }
}
