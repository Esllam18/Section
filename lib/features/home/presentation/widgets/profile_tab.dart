// lib/features/home/presentation/widgets/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/theme/theme_cubit.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr(context))),
      body: ListView(
        padding: context.rSymmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Avatar + name ──────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Settings card ──────────────────────────────────────────────
          _SectionLabel(label: 'settings'.tr(context)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // Dark mode toggle
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (ctx, state) => SwitchListTile(
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (v) =>
                        ctx.read<ThemeCubit>().toggleTheme(v),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text('dark_mode'.tr(context),
                        style: theme.textTheme.bodyMedium),
                    activeColor: AppColors.primary,
                  ),
                ),
                Divider(height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.grey200),
                // Language switch
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text('language'.tr(context),
                      style: theme.textTheme.bodyMedium),
                  trailing: BlocBuilder<LocaleCubit, ChangeLocaleState>(
                    builder: (ctx, state) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LangChip(
                          label: 'EN',
                          selected: state.locale.languageCode == 'en',
                          onTap: () => ctx.read<LocaleCubit>().changeLanguage('en'),
                        ),
                        const SizedBox(width: 6),
                        _LangChip(
                          label: 'AR',
                          selected: state.locale.languageCode == 'ar',
                          onTap: () => ctx.read<LocaleCubit>().changeLanguage('ar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Logout ─────────────────────────────────────────────────────
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('logout'.tr(context),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.error)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigation.offAllNamed(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                letterSpacing: 0.8)),
      );
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.primary,
              )),
        ),
      );
}
