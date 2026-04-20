// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/theme/theme_cubit.dart';
import 'package:section/core/theme/theme_state.dart';
import 'package:section/features/auth/presentation/screens/login_screen.dart';
import 'package:section/features/cart/presentation/screens/cart_screen.dart';
import 'package:section/features/orders/presentation/screens/orders_screen.dart';
import 'package:section/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:section/features/notifications/presentation/screens/notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = true;
  bool _notifOrders = true;
  bool _notifReplies = true;
  bool _notifResources = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool('notifications_enabled') ?? true;
      _notifOrders = prefs.getBool('notif_order_updates') ?? true;
      _notifReplies = prefs.getBool('notif_community_replies') ?? true;
      _notifResources = prefs.getBool('notif_new_resources') ?? true;
    });
    // Package info — skip if not installed
    // try { final info = await PackageInfo.fromPlatform(); setState(() => _appVersion = info.version); } catch (_) {}
  }

  Future<void> _setSwitchPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (ctx, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (tCtx, themeState) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: Navigation.back),
              title: Text(isAr ? 'الإعدادات' : 'Settings',
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            ),
            body:
                ListView(padding: const EdgeInsets.all(AppSizes.md), children: [
              // Appearance
              _sectionTitle(isAr ? 'المظهر' : 'Appearance'),
              _settingCard([
                _SettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: isAr ? 'الوضع الداكن' : 'Dark Mode',
                  trailing: Switch(
                    value: themeState.isDark,
                    onChanged: (v) => tCtx.read<ThemeCubit>().setTheme(v),
                    activeThumbColor: AppColors.secondary,
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              // Language
              _sectionTitle(isAr ? 'اللغة' : 'Language'),
              _settingCard([
                _SettingTile(
                  icon: Icons.language_outlined,
                  title: isAr ? 'اللغة' : 'Language',
                  subtitle: isAr ? 'العربية' : 'English',
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _langBtn(
                        ctx, 'ar', 'ع', locale.locale.languageCode == 'ar'),
                    const SizedBox(width: 8),
                    _langBtn(
                        ctx, 'en', 'EN', locale.locale.languageCode == 'en'),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              // Notifications
              _sectionTitle(isAr ? 'الإشعارات' : 'Notifications'),
              _settingCard([
                _SettingTile(
                  icon: Icons.notifications_outlined,
                  title: isAr ? 'تفعيل الإشعارات' : 'Enable Notifications',
                  trailing: Switch(
                    value: _notifEnabled,
                    onChanged: (v) {
                      setState(() => _notifEnabled = v);
                      _setSwitchPref('notifications_enabled', v);
                    },
                    activeThumbColor: AppColors.secondary,
                  ),
                ),
                if (_notifEnabled) ...[
                  _SettingTile(
                    icon: Icons.shopping_bag_outlined,
                    title: isAr ? 'تحديثات الطلبات' : 'Order Updates',
                    trailing: Switch(
                        value: _notifOrders,
                        onChanged: (v) {
                          setState(() => _notifOrders = v);
                          _setSwitchPref('notif_order_updates', v);
                        },
                        activeThumbColor: AppColors.secondary),
                  ),
                  _SettingTile(
                    icon: Icons.reply_outlined,
                    title: isAr ? 'ردود المجتمع' : 'Community Replies',
                    trailing: Switch(
                        value: _notifReplies,
                        onChanged: (v) {
                          setState(() => _notifReplies = v);
                          _setSwitchPref('notif_community_replies', v);
                        },
                        activeThumbColor: AppColors.secondary),
                  ),
                  _SettingTile(
                    icon: Icons.menu_book_outlined,
                    title: isAr ? 'مصادر دراسية جديدة' : 'New Study Resources',
                    trailing: Switch(
                        value: _notifResources,
                        onChanged: (v) {
                          setState(() => _notifResources = v);
                          _setSwitchPref('notif_new_resources', v);
                        },
                        activeThumbColor: AppColors.secondary),
                  ),
                ],
              ]),
              const SizedBox(height: 14),
              // Shopping
              _sectionTitle(isAr ? 'التسوق' : 'Shopping'),
              _settingCard([
                _SettingTile(
                    icon: Icons.shopping_cart_outlined,
                    title: isAr ? 'سلة التسوق' : 'Cart',
                    onTap: () => Navigation.to(const CartScreen())),
                _SettingTile(
                    icon: Icons.receipt_long_outlined,
                    title: isAr ? 'طلباتي' : 'My Orders',
                    onTap: () => Navigation.to(const OrdersScreen())),
                _SettingTile(
                    icon: Icons.favorite_border_rounded,
                    title: isAr ? 'المفضلة' : 'Favorites',
                    onTap: () => Navigation.to(const FavoritesScreen())),
              ]),
              const SizedBox(height: 14),
              // Account
              _sectionTitle(isAr ? 'الحساب' : 'Account'),
              _settingCard([
                _SettingTile(
                    icon: Icons.notifications_outlined,
                    title: isAr ? 'الإشعارات' : 'Notifications',
                    onTap: () => Navigation.to(const NotificationsScreen())),
                _SettingTile(
                    icon: Icons.lock_outline,
                    title: isAr ? 'تغيير كلمة المرور' : 'Change Password',
                    onTap: () {}),
              ]),
              const SizedBox(height: 14),
              // About
              _sectionTitle(isAr ? 'عن التطبيق' : 'About'),
              _settingCard([
                _SettingTile(
                    icon: Icons.info_outline,
                    title: isAr ? 'الإصدار' : 'App Version',
                    subtitle: _appVersion),
                _SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                    onTap: () {}),
                _SettingTile(
                    icon: Icons.description_outlined,
                    title: isAr ? 'الشروط والأحكام' : 'Terms of Service',
                    onTap: () {}),
                _SettingTile(
                    icon: Icons.star_outline_rounded,
                    title: isAr ? 'قيّم التطبيق' : 'Rate App',
                    onTap: () {}),
              ]),
              const SizedBox(height: 14),
              // Support
              _sectionTitle(isAr ? 'الدعم' : 'Support'),
              _settingCard([
                _SettingTile(
                    icon: Icons.support_agent_outlined,
                    title: isAr ? 'تواصل معنا' : 'Contact Us',
                    onTap: () {}),
                _SettingTile(
                    icon: Icons.bug_report_outlined,
                    title: isAr ? 'الإبلاغ عن مشكلة' : 'Report a Bug',
                    onTap: () {}),
              ]),
              const SizedBox(height: 24),
              // Logout
              OutlinedButton.icon(
                onPressed: () async {
                  await SupabaseService.auth.signOut();
                  Navigation.offAll(const LoginScreen());
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(isAr ? 'تسجيل الخروج' : 'Logout',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondaryLight)),
      );

  Widget _settingCard(List<Widget> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5),
      ),
      child: Column(
          children: items.asMap().entries.map((e) {
        return Column(children: [
          e.value,
          if (e.key < items.length - 1) const Divider(height: 1, indent: 52)
        ]);
      }).toList()),
    );
  }

  Widget _langBtn(BuildContext ctx, String code, String label, bool selected) =>
      GestureDetector(
          onTap: () => ctx.read<LocaleCubit>().changeLanguage(code),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: selected ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected
                          ? AppColors.secondary
                          : AppColors.dividerLight)),
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondaryLight))));
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingTile(
      {required this.icon,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 19, color: AppColors.primary)),
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondaryLight))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondaryLight)
                : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      );
}
