// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/features/auth/data/repositories/auth_repository.dart';
import 'package:section/features/auth/presentation/cubit/login_cubit.dart';
import 'package:section/features/auth/presentation/cubit/login_state.dart';
import 'package:section/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:section/features/auth/presentation/screens/register_screen.dart';
import 'package:section/features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'package:section/layout/main_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LoginCubit(AuthRepository()),
    child: const _LoginView(),
  );
}

class _LoginView extends StatefulWidget {
  const _LoginView();
  @override State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (_, s) {
        if (s is LoginSuccess) {
          s.user.isProfileComplete
              ? Navigation.offAll(const MainLayout())
              : Navigation.offAll(const ProfileSetupScreen());
        } else if (s is LoginError) {
          CustomSnackBar.show(message: s.message, type: SnackBarType.error);
        }
      },
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (_, locale) {
          final isAr = locale.locale.languageCode == 'ar';
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    const SizedBox(height: 32),
                    _logo(),
                    const SizedBox(height: 32),
                    Text(isAr ? 'أهلاً بك' : 'Welcome back',
                      style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(isAr ? 'سجل الدخول إلى حسابك' : 'Login to your account',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _emailCtrl,
                      hint: isAr ? 'البريد الإلكتروني' : 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || !v.contains('@')) ? (isAr ? 'بريد غير صحيح' : 'Invalid email') : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _passCtrl,
                      hint: isAr ? 'كلمة المرور' : 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.length < 6) ? (isAr ? 'كلمة مرور قصيرة' : 'Too short') : null,
                    ),
                    Align(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigation.to(const ForgotPasswordScreen()),
                        child: Text(isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                          style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (ctx, s) => CustomButton(
                        label: isAr ? 'تسجيل الدخول' : 'Login',
                        onTap: () { if (_formKey.currentState!.validate()) ctx.read<LoginCubit>().login(_emailCtrl.text, _passCtrl.text); },
                        isLoading: s is LoginLoading,
                        useGradient: true,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(isAr ? 'أو' : 'OR', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight, fontSize: 13))),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: AppSizes.md),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (ctx, s) => OutlinedButton(
                        onPressed: s is LoginLoading ? null : () => ctx.read<LoginCubit>().loginWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: AppColors.dividerLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('G', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF4285F4))),
                          const SizedBox(width: 10),
                          Text(isAr ? 'المتابعة عبر جوجل' : 'Continue with Google',
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimaryLight)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(isAr ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
                      GestureDetector(
                        onTap: () => Navigation.to(const RegisterScreen()),
                        child: Text(isAr ? 'إنشاء حساب' : 'Register',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _logo() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 44, height: 44,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(11)),
      child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24)),
    const SizedBox(width: 10),
    const Text('Section', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary)),
  ]);
}
