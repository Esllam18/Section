// lib/features/home/presentation/view/home_view.dart
// Phase 1 shell — full implementation in Session B
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAR ? 'سيكشن' : 'Section'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Navigation.offAllNamed(AppRoutes.login);
              }),
        ],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.white, size: 48)),
          const SizedBox(height: 24),
          Text(isAR ? '🎉 تم إعداد Session A بنجاح!' : '🎉 Session A Complete!',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
              isAR
                  ? 'تم تطبيق: الـ Splash، اختيار اللغة والمظهر، الـ Onboarding، المصادقة الكاملة (بما فيها Google)، وإكمال الملف الشخصي.'
                  : 'Implemented: Splash, Language & Theme picker, Onboarding, Full Auth (incl. Google), Complete Profile.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(user?.email ?? '',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 32),
          Text(
              isAR
                  ? 'Session B — المتجر والسلة والدفع قادمة.'
                  : 'Session B — Store, Cart & Payment coming next.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4)),
              textAlign: TextAlign.center),
        ]),
      )),
    );
  }
}
