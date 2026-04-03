// lib/features/auth/presentation/view/sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/or_divider_widget.dart';
import '../widgets/social_login_button_widget.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigation.offAllNamed(AppRoutes.completeProfile);
        } else if (state is AuthError) {
          CustomSnackBar.show(context,
              message: state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSymmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.h(0.03)),

                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    direction: SlideDirection.up,
                    slideDistance: 24,
                    child: AuthHeaderWidget(
                      title: 'create_account'.tr(context),
                      subtitle: 'sign_up_subtitle'.tr(context),
                    ),
                  ),

                  SizedBox(height: context.r(32)),

                  // Email
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 100),
                    direction: SlideDirection.up,
                    slideDistance: 20,
                    child: CustomTextField(
                      hint: 'email'.tr(context),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'email_required'.tr(context);
                        if (!v.contains('@')) return 'email_invalid'.tr(context);
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: context.r(14)),

                  // Password
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 170),
                    direction: SlideDirection.up,
                    slideDistance: 20,
                    child: CustomTextField(
                      hint: 'password'.tr(context),
                      controller: _passCtrl,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'password_required'.tr(context);
                        if (v.length < 6) return 'password_min'.tr(context);
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: context.r(14)),

                  // Confirm Password
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 240),
                    direction: SlideDirection.up,
                    slideDistance: 20,
                    child: CustomTextField(
                      hint: 'confirm_password'.tr(context),
                      controller: _confirmCtrl,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      onSubmitted: (_) => _onSignUp(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'password_required'.tr(context);
                        if (v != _passCtrl.text) return 'passwords_not_match'.tr(context);
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: context.r(24)),

                  // Sign Up Button
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 300),
                    direction: SlideDirection.up,
                    slideDistance: 16,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (_, state) => CustomButton(
                        label: 'sign_up'.tr(context),
                        onTap: _onSignUp,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                  ),

                  SizedBox(height: context.r(24)),

                  AppAnimations.fade(
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 360),
                    child: const OrDividerWidget(),
                  ),

                  SizedBox(height: context.r(20)),

                  // Google
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 420),
                    direction: SlideDirection.up,
                    slideDistance: 16,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (_, state) => SocialLoginButton(
                        label: 'continue_google'.tr(context),
                        iconPath:
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        onTap: () => context.read<AuthCubit>().signInWithGoogle(),
                        isLoading: state is AuthLoading,
                      ),
                    ),
                  ),

                  SizedBox(height: context.r(32)),

                  // Login Link
                  AppAnimations.fade(
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 480),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('already_have_account'.tr(context),
                            style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => Navigation.back(),
                          child: Text('login'.tr(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
