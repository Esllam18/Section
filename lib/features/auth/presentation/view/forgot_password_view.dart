// lib/features/auth/presentation/view/forgot_password_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header_widget.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().resetPassword(_emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthResetEmailSent) {
          CustomSnackBar.show(
            context,
            message: 'reset_email_sent'.tr(context),
            type: SnackBarType.success,
            duration: const Duration(seconds: 5),
          );
          Navigation.back();
        } else if (state is AuthError) {
          CustomSnackBar.show(context,
              message: state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: Navigation.back,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSymmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.h(0.04)),

                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    direction: SlideDirection.up,
                    slideDistance: 24,
                    child: AuthHeaderWidget(
                      title: 'forgot_password_title'.tr(context),
                      subtitle: 'forgot_password_subtitle'.tr(context),
                    ),
                  ),

                  SizedBox(height: context.r(36)),

                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 150),
                    direction: SlideDirection.up,
                    slideDistance: 20,
                    child: CustomTextField(
                      hint: 'email'.tr(context),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      onSubmitted: (_) => _onSubmit(),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'email_required'.tr(context);
                        if (!v.contains('@')) return 'email_invalid'.tr(context);
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: context.r(28)),

                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 250),
                    direction: SlideDirection.up,
                    slideDistance: 16,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (_, state) => CustomButton(
                        label: 'send_reset_link'.tr(context),
                        onTap: _onSubmit,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                  ),

                  SizedBox(height: context.r(20)),

                  // Info note
                  AppAnimations.fade(
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 350),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.info, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'reset_email_note'.tr(context),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.info,
                                    height: 1.5,
                                  ),
                            ),
                          ),
                        ],
                      ),
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
