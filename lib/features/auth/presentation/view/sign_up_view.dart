// lib/features/auth/presentation/view/sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gap.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});
  @override
  State<SignUpView> createState() => _State();
}

class _State extends State<SignUpView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _passNode = FocusNode();
  final _confirmNode = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _passNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context
        .read<AuthCubit>()
        .signUp(email: _email.text.trim(), password: _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, st) {
        if (st is AuthSuccess) {
          Navigation.offAllNamed(AppRoutes.completeProfile);
        } else if (st is AuthFailure)
          AppSnackBar.show(ctx, message: st.message, type: SnackType.error);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSym(h: 24, v: 20),
            child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(context.h(0.03)),

                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        dir: SlideDir.up,
                        dist: 20,
                        child: AuthHeader(
                            title: isAR ? 'إنشاء حساب جديد' : 'Create Account',
                            subtitle: isAR
                                ? 'انضم إلى آلاف الطلاب اليوم'
                                : 'Join thousands of students today')),

                    Gap(context.r(28)),

                    // Email
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 80),
                        dir: SlideDir.up,
                        dist: 16,
                        child: CustomTextField(
                          hint: isAR ? 'البريد الإلكتروني' : 'Email address',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefix: const Icon(Icons.email_outlined, size: 20),
                          onSubmitted: (_) => _passNode.requestFocus(),
                          validator: (v) => Validators.email(v,
                              msg: isAR
                                  ? 'البريد الإلكتروني مطلوب'
                                  : 'Email is required'),
                        )),

                    Gap(context.r(14)),

                    // Password
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 140),
                        dir: SlideDir.up,
                        dist: 16,
                        child: CustomTextField(
                          hint: isAR ? 'كلمة المرور' : 'Password',
                          controller: _pass,
                          isPassword: true,
                          focusNode: _passNode,
                          textInputAction: TextInputAction.next,
                          prefix:
                              const Icon(Icons.lock_outline_rounded, size: 20),
                          onSubmitted: (_) => _confirmNode.requestFocus(),
                          validator: (v) => Validators.password(v,
                              msg: isAR
                                  ? 'كلمة المرور مطلوبة'
                                  : 'Password is required'),
                        )),

                    Gap(context.r(14)),

                    // Confirm password
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 190),
                        dir: SlideDir.up,
                        dist: 16,
                        child: CustomTextField(
                          hint: isAR ? 'تأكيد كلمة المرور' : 'Confirm password',
                          controller: _confirm,
                          isPassword: true,
                          focusNode: _confirmNode,
                          textInputAction: TextInputAction.done,
                          prefix:
                              const Icon(Icons.lock_outline_rounded, size: 20),
                          onSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAR
                                  ? 'الرجاء تأكيد كلمة المرور'
                                  : 'Please confirm your password';
                            }
                            if (v != _pass.text) {
                              return isAR
                                  ? 'كلمتا المرور غير متطابقتين'
                                  : 'Passwords do not match';
                            }
                            return null;
                          },
                        )),

                    // Password hint
                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 220),
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 4, right: 4),
                            child: Text(
                                isAR
                                    ? '• 8 أحرف على الأقل  • حرف كبير  • رقم واحد على الأقل'
                                    : '• Min 8 chars  • One uppercase  • One number',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4))))),

                    Gap(context.r(20)),

                    // Sign up button
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 260),
                        dir: SlideDir.up,
                        dist: 14,
                        child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (_, st) => CustomButton(
                                label: isAR ? 'إنشاء الحساب' : 'Create Account',
                                onTap: _submit,
                                isLoading: st is AuthLoading))),

                    Gap(context.r(20)),

                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 300),
                        child: OrDivider(
                            label: isAR
                                ? 'أو تابع باستخدام'
                                : 'Or continue with')),

                    Gap(context.r(16)),

                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 340),
                        dir: SlideDir.up,
                        dist: 14,
                        child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (_, st) => GoogleSignInButton(
                                label: isAR
                                    ? 'المتابعة عبر جوجل'
                                    : 'Continue with Google',
                                isLoading: st is AuthLoading,
                                onTap: () => context
                                    .read<AuthCubit>()
                                    .signInWithGoogle()))),

                    Gap(context.r(28)),

                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  isAR
                                      ? 'لديك حساب بالفعل؟'
                                      : 'Already have an account?',
                                  style: theme.textTheme.bodyMedium),
                              TextButton(
                                  onPressed: Navigation.back,
                                  child: Text(isAR ? 'تسجيل الدخول' : 'Login')),
                            ])),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
