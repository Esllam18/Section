// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/features/cart/presentation/screens/cart_screen.dart';
import 'package:section/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:section/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:section/features/orders/presentation/screens/orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _faculty = '';
  String? _avatarUrl;
  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    final p = await SupabaseService.client
        .from('profiles')
        .select('full_name, faculty, academic_year, avatar_url')
        .eq('id', uid)
        .maybeSingle();
    if (mounted && p != null) {
      setState(() {
        _name = p['full_name'] ?? '';
        _faculty = p['faculty'] ?? '';
        _avatarUrl = p['avatar_url'];
      });
    }
    // Load unread notification count
    try {
      final notifs = await SupabaseService.client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);
      if (mounted) setState(() => _unreadNotifs = (notifs as List).length);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18)),
              const SizedBox(width: 8),
              const Text('Section', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 20)),
            ]),
            actions: [
              // Notification bell
              Stack(children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () async {
                    await Navigation.to(const NotificationsScreen());
                    _load();
                  },
                ),
                if (_unreadNotifs > 0)
                  Positioned(top: 6, right: 6,
                    child: Container(width: 9, height: 9,
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
              ]),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── Hero greeting card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        isAr
                            ? 'أهلاً${_name.isNotEmpty ? "، $_name" : ""}! 👋'
                            : 'Hello${_name.isNotEmpty ? ", $_name" : ""}! 👋',
                        style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700,
                            fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(
                        isAr ? 'ماذا تريد اليوم؟' : 'What would you like to do today?',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                            color: Colors.white.withOpacity(0.85))),
                      if (_faculty.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(_faculty.toUpperCase(),
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                                color: Colors.white, fontWeight: FontWeight.w600))),
                      ],
                    ])),
                    if (_avatarUrl != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2)),
                        child: ClipOval(
                          child: CachedImageWidget(imageUrl: _avatarUrl, width: 52, height: 52))),
                    ],
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Quick action cards ─────────────────────────────────────
                Text(isAr ? 'استكشف Section' : 'Explore Section',
                  style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _QuickCard(
                      icon: Icons.shopping_bag_outlined,
                      label: isAr ? 'المتجر' : 'Store',
                      sub: isAr ? 'أدواتك الطبية' : 'Medical tools',
                      color: AppColors.primary,
                    ),
                    _QuickCard(
                      icon: Icons.people_outline,
                      label: isAr ? 'المجتمع' : 'Community',
                      sub: isAr ? 'تواصل مع الزملاء' : 'Connect with peers',
                      color: const Color(0xFF7C4DFF),
                    ),
                    _QuickCard(
                      icon: Icons.menu_book_outlined,
                      label: isAr ? 'الدراسة' : 'Study',
                      sub: isAr ? 'مذكرات وامتحانات' : 'Notes & exams',
                      color: AppColors.success,
                    ),
                    _QuickCard(
                      icon: Icons.smart_toy_outlined,
                      label: isAr ? 'مساعد AI' : 'AI',
                      sub: isAr ? 'اسأل أي سؤال' : 'Ask anything',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── My Orders / Cart shortcut row ─────────────────────────
                Row(children: [
                  Expanded(child: _ShortcutTile(
                    icon: Icons.receipt_long_outlined,
                    label: isAr ? 'طلباتي' : 'My Orders',
                    color: AppColors.warning,
                    onTap: () => Navigation.to(const OrdersScreen()),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _ShortcutTile(
                    icon: Icons.favorite_border_rounded,
                    label: isAr ? 'المفضلة' : 'Favorites',
                    color: AppColors.error,
                    onTap: () => Navigation.to(const FavoritesScreen()),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _ShortcutTile(
                    icon: Icons.shopping_cart_outlined,
                    label: isAr ? 'السلة' : 'Cart',
                    color: AppColors.secondary,
                    onTap: () => Navigation.to(const CartScreen()),
                  )),
                ]),
                const SizedBox(height: 20),

                // ── AI promo banner ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.secondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.smart_toy_rounded, color: AppColors.secondary, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(isAr ? 'مساعد Section الذكي' : 'Section AI Assistant',
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(
                        isAr
                            ? 'اسألني عن الدراسة، الكريبس، التشريح، أي شيء!'
                            : 'Ask me about Krebs cycle, anatomy, anything!',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                            color: AppColors.textSecondaryLight)),
                    ])),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondary),
                  ]),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  const _QuickCard({required this.icon, required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.09),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14, color: color)),
        Text(sub, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
      ]),
    ]),
  );
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ShortcutTile({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}
