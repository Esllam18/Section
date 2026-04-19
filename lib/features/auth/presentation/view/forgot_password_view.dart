// lib/features/auth/presentation/view/forgot_password_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gap.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _State();
}

class _State extends State<ForgotPasswordView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context.read<AuthCubit>().resetPassword(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, st) {
        if (st is AuthResetSent) {
          AppSnackBar.show(ctx,
              type: SnackType.success,
              duration: const Duration(seconds: 5),
              message: isAR
                  ? 'تم الإرسال! تحقق من بريدك الإلكتروني.'
                  : 'Sent! Check your inbox.');
          Navigation.back();
        } else if (st is AuthFailure) {
          AppSnackBar.show(ctx, message: st.message, type: SnackType.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
            leading: const IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: Navigation.back)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSym(h: 24, v: 16),
            child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(context.h(0.04)),
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        dir: SlideDir.up,
                        dist: 20,
                        child: AuthHeader(
                            title:
                                isAR ? 'استعادة كلمة المرور' : 'Reset Password',
                            subtitle: isAR
                                ? 'أدخل بريدك وسنرسل لك رابط الاستعادة'
                                : 'Enter your email and we\'ll send a reset link')),
                    Gap(context.r(32)),
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 120),
                        dir: SlideDir.up,
                        dist: 16,
                        child: CustomTextField(
                          hint: isAR ? 'البريد الإلكتروني' : 'Email address',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefix: const Icon(Icons.email_outlined, size: 20),
                          onSubmitted: (_) => _submit(),
                          validator: (v) => Validators.email(v,
                              msg: isAR
                                  ? 'البريد الإلكتروني مطلوب'
                                  : 'Email is required'),
                        )),
                    Gap(context.r(24)),
                    AppAnimations.fadeSlide(
                        duration: AppDurations.slow,
                        delay: const Duration(milliseconds: 200),
                        dir: SlideDir.up,
                        dist: 14,
                        child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (_, st) => CustomButton(
                                label: isAR
                                    ? 'إرسال رابط الاستعادة'
                                    : 'Send Reset Link',
                                onTap: _submit,
                                isLoading: st is AuthLoading))),
                    Gap(context.r(20)),
                    AppAnimations.fade(
                      duration: AppDurations.slow,
                      delay: const Duration(milliseconds: 280),
                      child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.info.withOpacity(0.2))),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: AppColors.info, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        isAR
                                            ? 'إذا لم تجد الرسالة، تحقق من مجلد البريد العشوائي.'
                                            : 'If you don\'t see the email, check your spam folder.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.info,
                                                height: 1.5))),
                              ])),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
