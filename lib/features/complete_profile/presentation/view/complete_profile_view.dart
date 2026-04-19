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
import '../cubit/complete_profile_cubit.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/profile_dropdown.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});
  @override
  State<CompleteProfileView> createState() => _State();
}

class _State extends State<CompleteProfileView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  String? _college, _year, _gender;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  // ── Localised lists ────────────────────────────────────────────────────────
  List<String> _colleges(bool ar) => ar
      ? [
          'الطب البشري',
          'طب الأسنان',
          'الصيدلة',
          'التمريض',
          'العلاج الطبيعي',
          'العلوم الصحية',
          'الطب البيطري',
          'أخرى',
        ]
      : [
          'Medicine',
          'Dentistry',
          'Pharmacy',
          'Nursing',
          'Physical Therapy',
          'Health Sciences',
          'Veterinary',
          'Other',
        ];

  List<String> _years(bool ar) => ar
      ? [
          'السنة الأولى',
          'السنة الثانية',
          'السنة الثالثة',
          'السنة الرابعة',
          'السنة الخامسة',
          'السنة السادسة',
          'الامتياز'
        ]
      : [
          'Year 1',
          'Year 2',
          'Year 3',
          'Year 4',
          'Year 5',
          'Year 6',
          'Internship'
        ];

  List<String> _genders(bool ar) => ar
      ? ['ذكر', 'أنثى', 'أفضل عدم الإفصاح']
      : ['Male', 'Female', 'Prefer not to say'];

  void _submit(bool isAR) {
    if (!_form.currentState!.validate()) return;
    if (_college == null) {
      AppSnackBar.show(context,
          type: SnackType.warning,
          message: isAR ? 'يرجى اختيار الكلية' : 'Please select your college');
      return;
    }
    if (_year == null) {
      AppSnackBar.show(context,
          type: SnackType.warning,
          message:
              isAR ? 'يرجى اختيار سنة الدراسة' : 'Please select your year');
      return;
    }
    context.read<CompleteProfileCubit>().save(
        fullName: _name.text,
        phone: _phone.text.trim().isEmpty ? null : _phone.text,
        bio: _bio.text.trim().isEmpty ? null : _bio.text,
        college: _college!,
        yearOfStudy: _year!,
        gender: _gender);
  }

  Widget _animated({required int delayMs, required Widget child}) =>
      AppAnimations.fadeSlide(
          duration: AppDurations.slow,
          delay: Duration(milliseconds: delayMs),
          dir: SlideDir.up,
          dist: 16,
          child: child);

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    final theme = Theme.of(context);

    return BlocListener<CompleteProfileCubit, CompleteProfileState>(
      listener: (ctx, st) {
        if (st is CompleteProfileSuccess) {
          Navigation.offAllNamed(AppRoutes.home);
        } else if (st is CompleteProfileError)
          AppSnackBar.show(ctx, message: st.message, type: SnackType.error);
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(isAR ? 'أكمل ملفك الشخصي' : 'Complete Profile'),
            automaticallyImplyLeading: false),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.rSym(h: 24, v: 20),
            child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle
                    _animated(
                        delayMs: 0,
                        child: Text(
                            isAR
                                ? 'ساعدنا في تخصيص تجربتك.'
                                : 'Help us personalise your experience.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.55)),
                            textAlign: TextAlign.center)),

                    Gap(context.r(22)),

                    // Avatar
                    _animated(
                        delayMs: 60,
                        child: Center(
                            child: BlocBuilder<CompleteProfileCubit,
                                    CompleteProfileState>(
                                builder: (ctx, st) => AvatarPicker(
                                    image: st is ProfileImagePicked
                                        ? st.file
                                        : ctx
                                            .read<CompleteProfileCubit>()
                                            .pickedImage,
                                    onTap: () => ctx
                                        .read<CompleteProfileCubit>()
                                        .pickImage())))),

                    Gap(context.r(24)),

                    // Full name
                    _animated(
                        delayMs: 100,
                        child: CustomTextField(
                          hint: isAR ? 'الاسم الكامل' : 'Full name',
                          controller: _name,
                          prefix: const Icon(Icons.person_outline_rounded,
                              size: 20),
                          validator: (v) => Validators.fullName(v),
                        )),

                    Gap(context.r(14)),

                    // Phone
                    _animated(
                        delayMs: 150,
                        child: CustomTextField(
                          hint: isAR
                              ? 'رقم الهاتف (اختياري)'
                              : 'Phone number (optional)',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          prefix: const Icon(Icons.phone_outlined, size: 20),
                          validator: Validators.phone,
                        )),

                    Gap(context.r(14)),

                    // College
                    _animated(
                        delayMs: 200,
                        child: ProfileDropdown(
                            hint: isAR ? 'اختر كليتك' : 'Select college',
                            value: _college,
                            icon: Icons.school_outlined,
                            items: _colleges(isAR),
                            onChanged: (v) => setState(() => _college = v))),

                    Gap(context.r(14)),

                    // Year
                    _animated(
                        delayMs: 250,
                        child: ProfileDropdown(
                            hint: isAR ? 'سنة الدراسة' : 'Year of study',
                            value: _year,
                            icon: Icons.calendar_today_outlined,
                            items: _years(isAR),
                            onChanged: (v) => setState(() => _year = v))),

                    Gap(context.r(14)),

                    // Gender
                    _animated(
                        delayMs: 300,
                        child: ProfileDropdown(
                            hint:
                                isAR ? 'الجنس (اختياري)' : 'Gender (optional)',
                            value: _gender,
                            icon: Icons.wc_outlined,
                            items: _genders(isAR),
                            onChanged: (v) => setState(() => _gender = v))),

                    Gap(context.r(14)),

                    // Bio
                    _animated(
                        delayMs: 340,
                        child: CustomTextField(
                          hint: isAR
                              ? 'نبذة عنك (اختياري)'
                              : 'Short bio (optional)',
                          controller: _bio,
                          maxLines: 3,
                          prefix: const Icon(Icons.edit_note_rounded, size: 20),
                        )),

                    Gap(context.r(28)),

                    // Save button
                    _animated(
                        delayMs: 400,
                        child: BlocBuilder<CompleteProfileCubit,
                                CompleteProfileState>(
                            builder: (_, st) => CustomButton(
                                label: isAR ? 'حفظ ومتابعة' : 'Save & Continue',
                                onTap: () => _submit(isAR),
                                isLoading: st is CompleteProfileLoading))),

                    Gap(context.r(12)),

                    // Skip
                    _animated(
                        delayMs: 440,
                        child: TextButton(
                            onPressed: () =>
                                Navigation.offAllNamed(AppRoutes.home),
                            child: Text(isAR ? 'تخطى الآن' : 'Skip for now'))),

                    const Gap(20),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
