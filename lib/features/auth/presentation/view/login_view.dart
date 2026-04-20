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

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _State();
}

class _State extends State<LoginView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passNode = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _passNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context
        .read<AuthCubit>()
        .signIn(email: _email.text.trim(), password: _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, st) {
        if (st is AuthSuccess) {
          Navigation.offAllNamed(
              st.needsProfile ? AppRoutes.home : AppRoutes.home);
        } else if (st is AuthFailure) {
          AppSnackBar.show(ctx, message: st.message, type: SnackType.error);
        }
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
                    Gap(context.h(0.04)),

                    // Header
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        dir: SlideDir.up,
                        dist: 20,
                        child: AuthHeader(
                            title: isAR ? 'مرحباً بعودتك' : 'Welcome Back',
                            subtitle: isAR
                                ? 'سجّل دخولك للمتابعة'
                                : 'Sign in to continue')),

                    Gap(context.r(32)),

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
                          textInputAction: TextInputAction.done,
                          prefix:
                              const Icon(Icons.lock_outline_rounded, size: 20),
                          onSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAR
                                  ? 'كلمة المرور مطلوبة'
                                  : 'Password is required';
                            }
                            return null;
                          },
                        )),

                    // Forgot password
                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 180),
                        child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                                onPressed: () => Navigation.toNamed(
                                    AppRoutes.forgotPassword),
                                child: Text(isAR
                                    ? 'نسيت كلمة المرور؟'
                                    : 'Forgot Password?')))),

                    Gap(context.r(4)),

                    // Login button
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 220),
                        dir: SlideDir.up,
                        dist: 14,
                        child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (_, st) => CustomButton(
                                label: isAR ? 'تسجيل الدخول' : 'Login',
                                onTap: _submit,
                                isLoading: st is AuthLoading))),

                    Gap(context.r(22)),

                    // Or divider
                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 280),
                        child: OrDivider(
                            label: isAR
                                ? 'أو تابع باستخدام'
                                : 'Or continue with')),

                    Gap(context.r(18)),

                    // Google
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

                    // Sign up link
                    AppAnimations.fade(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  isAR
                                      ? 'ليس لديك حساب؟'
                                      : "Don't have an account?",
                                  style: theme.textTheme.bodyMedium),
                              TextButton(
                                  onPressed: () =>
                                      Navigation.toNamed(AppRoutes.signUp),
                                  child: Text(isAR ? 'إنشاء حساب' : 'Sign Up')),
                            ])),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
