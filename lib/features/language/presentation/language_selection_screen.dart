// lib/features/language/presentation/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/features/onboarding/presentation/onboarding_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selected = 'ar';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (ctx, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(children: [
                const SizedBox(height: 48),
                _logo(),
                const SizedBox(height: 48),
                Text(isAr ? 'اختر اللغة' : 'Choose Language',
                  style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 28),
                  textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(isAr ? 'يمكنك تغييرها من الإعدادات' : 'You can change it later in settings',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight),
                  textAlign: TextAlign.center),
                const SizedBox(height: 48),
                Row(children: [
                  Expanded(child: _card(ctx, code: 'ar', flag: '🇪🇬', label: 'العربية')),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: _card(ctx, code: 'en', flag: '🌐', label: 'English')),
                ]),
                const Spacer(),
                CustomButton(
                  label: isAr ? 'متابعة' : 'Continue',
                  onTap: () => Navigation.offAll(const OnboardingScreen()),
                  useGradient: true,
                ),
                const SizedBox(height: AppSizes.lg),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext ctx, {required String code, required String flag, required String label}) {
    final sel = _selected == code;
    return GestureDetector(
      onTap: () { setState(() => _selected = code); ctx.read<LocaleCubit>().changeLanguage(code); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: sel ? AppColors.secondary.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: sel ? AppColors.secondary : AppColors.dividerLight, width: sel ? 2.5 : 1),
        ),
        child: Column(children: [
          Text(flag, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18,
            color: sel ? AppColors.secondary : AppColors.textPrimaryLight)),
        ]),
      ),
    );
  }

  Widget _logo() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 40, height: 40,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22)),
    const SizedBox(width: 10),
    const Text('Section', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.primary)),
  ]);
}
