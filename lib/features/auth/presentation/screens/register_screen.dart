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
import 'package:section/features/auth/presentation/cubit/register_cubit.dart';
import 'package:section/features/auth/presentation/cubit/register_state.dart';
import 'package:section/features/profile_setup/presentation/screens/profile_setup_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override Widget build(BuildContext context) => BlocProvider(create: (_) => RegisterCubit(AuthRepository()), child: const _RegisterView());
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();
  @override State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (_, s) {
        if (s is RegisterSuccess) Navigation.offAll(const ProfileSetupScreen());
        else if (s is RegisterError) CustomSnackBar.show(message: s.message, type: SnackBarType.error);
      },
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (_, locale) {
          final isAr = locale.locale.languageCode == 'ar';
          return Scaffold(
            appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back)),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Form(key: _key, child: Column(children: [
                  Text(isAr ? 'إنشاء حساب' : 'Create Account',
                    style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(isAr ? 'انضم إلى منصة Section الطبية' : 'Join the Section medical platform',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 32),
                  CustomTextField(controller: _nameCtrl, hint: isAr ? 'الاسم الكامل' : 'Full Name', prefixIcon: Icons.person_outline, textInputAction: TextInputAction.next, validator: (v) => (v?.isEmpty ?? true) ? (isAr ? 'مطلوب' : 'Required') : null),
                  const SizedBox(height: AppSizes.md),
                  CustomTextField(controller: _emailCtrl, hint: isAr ? 'البريد الإلكتروني' : 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: (v) => (v == null || !v.contains('@')) ? (isAr ? 'بريد غير صحيح' : 'Invalid email') : null),
                  const SizedBox(height: AppSizes.md),
                  CustomTextField(controller: _passCtrl, hint: isAr ? 'كلمة المرور (8 أحرف على الأقل)' : 'Password (min 8 chars)', prefixIcon: Icons.lock_outline, isPassword: true, textInputAction: TextInputAction.next, validator: (v) => (v == null || v.length < 8) ? (isAr ? 'يجب 8 أحرف على الأقل' : 'Min 8 characters') : null),
                  const SizedBox(height: AppSizes.md),
                  CustomTextField(controller: _confirmCtrl, hint: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password', prefixIcon: Icons.lock_outline, isPassword: true, textInputAction: TextInputAction.done, validator: (v) => v != _passCtrl.text ? (isAr ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match') : null),
                  const SizedBox(height: AppSizes.xl),
                  BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (ctx, s) => CustomButton(label: isAr ? 'إنشاء الحساب' : 'Create Account',
                      onTap: () { if (_key.currentState!.validate()) ctx.read<RegisterCubit>().register(_emailCtrl.text, _passCtrl.text); },
                      isLoading: s is RegisterLoading, useGradient: true)),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(isAr ? 'لديك حساب؟ ' : 'Have an account? ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
                    GestureDetector(onTap: Navigation.back,
                      child: Text(isAr ? 'تسجيل الدخول' : 'Login',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  ]),
                  const SizedBox(height: 24),
                ])),
              ),
            ),
          );
        },
      ),
    );
  }
}
