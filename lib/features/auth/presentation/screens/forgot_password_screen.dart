import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:section/core/constants/app_assets.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/features/auth/data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _loading = false, _sent = false;

  @override void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send(bool isAr) async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthRepository().sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) setState(() { _loading = false; _sent = true; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); CustomSnackBar.show(message: e.toString(), type: SnackBarType.error); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: _sent ? Column(children: [
                const SizedBox(height: 32),
                Lottie.asset(AppAssets.lottieSuccess, width: 180, height: 180, repeat: false),
                const SizedBox(height: 24),
                Text(isAr ? 'تم الإرسال!' : 'Email Sent!', style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 26), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(isAr ? 'تحقق من بريدك الإلكتروني واتبع الرابط' : 'Check your inbox and follow the reset link',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight, height: 1.6), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                CustomButton(label: isAr ? 'العودة' : 'Back to Login', onTap: Navigation.back, isOutlined: true, backgroundColor: AppColors.primary, textColor: AppColors.primary, width: 200),
              ]) : Form(key: _key, child: Column(children: [
                Text(isAr ? 'نسيت كلمة المرور' : 'Forgot Password',
                  style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 26)),
                const SizedBox(height: 8),
                Text(isAr ? 'أدخل بريدك الإلكتروني لاستلام رابط الاستعادة' : 'Enter your email to receive a reset link',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 32),
                CustomTextField(controller: _emailCtrl, hint: isAr ? 'البريد الإلكتروني' : 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? (isAr ? 'بريد غير صحيح' : 'Invalid email') : null),
                const SizedBox(height: AppSizes.xl),
                CustomButton(label: isAr ? 'إرسال رابط الاستعادة' : 'Send Reset Link', onTap: () => _send(isAr), isLoading: _loading, useGradient: true),
              ])),
            ),
          ),
        );
      },
    );
  }
}
