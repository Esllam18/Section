// lib/features/complete_profile/presentation/view/complete_profile_view.dart

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
import '../cubit/complete_profile_cubit.dart';
import '../widgets/avatar_picker_widget.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _selectedCollege;
  String? _selectedYear;

  static const _colleges = [
    'Medicine',
    'Dentistry',
    'Pharmacy',
    'Nursing',
    'Physical Therapy',
    'Health Sciences',
    'Other',
  ];

  static const _years = [
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
    'Year 5',
    'Year 6',
    'Internship',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCollege == null) {
      CustomSnackBar.show(context,
          message: 'college_required'.tr(context), type: SnackBarType.warning);
      return;
    }
    if (_selectedYear == null) {
      CustomSnackBar.show(context,
          message: 'year_required'.tr(context), type: SnackBarType.warning);
      return;
    }
    context.read<CompleteProfileCubit>().saveProfile(
          fullName: _nameCtrl.text,
          phone: _phoneCtrl.text,
          college: _selectedCollege!,
          yearOfStudy: _selectedYear!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CompleteProfileCubit, CompleteProfileState>(
      listener: (context, state) {
        if (state is CompleteProfileSuccess) {
          Navigation.offAllNamed(AppRoutes.home);
        } else if (state is CompleteProfileError) {
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
                  SizedBox(height: context.r(16)),

                  // ── Title ─────────────────────────────────────────────────
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    direction: SlideDirection.up,
                    slideDistance: 20,
                    child: Column(
                      children: [
                        Text(
                          'complete_profile'.tr(context),
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'complete_profile_subtitle'.tr(context),
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.r(28)),

                  // ── Avatar picker ─────────────────────────────────────────
                  AppAnimations.combined(
                    type: CombineType.fadeScale,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 120),
                    beginScale: 0.7,
                    child: Center(
                      child: BlocBuilder<CompleteProfileCubit,
                          CompleteProfileState>(
                        builder: (context, state) => AvatarPickerWidget(
                          imageFile: state is CompleteProfileImagePicked
                              ? state.imageFile
                              : context
                                  .read<CompleteProfileCubit>()
                                  .pickedImage,
                          onTap: () =>
                              context.read<CompleteProfileCubit>().pickImage(),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: context.r(28)),

                  // ── Full Name ─────────────────────────────────────────────
                  _animatedField(
                    delay: 180,
                    child: CustomTextField(
                      hint: 'full_name'.tr(context),
                      controller: _nameCtrl,
                      prefixIcon:
                          const Icon(Icons.person_outline_rounded, size: 20),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'name_required'.tr(context)
                          : null,
                    ),
                  ),

                  SizedBox(height: context.r(14)),

                  // ── Phone (optional) ──────────────────────────────────────
                  _animatedField(
                    delay: 240,
                    child: CustomTextField(
                      hint: 'phone_optional'.tr(context),
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),

                  SizedBox(height: context.r(14)),

                  // ── College Dropdown ──────────────────────────────────────
                  _animatedField(
                    delay: 300,
                    child: _DropdownField(
                      hint: 'select_college'.tr(context),
                      value: _selectedCollege,
                      icon: Icons.school_outlined,
                      items: _colleges,
                      onChanged: (v) => setState(() => _selectedCollege = v),
                    ),
                  ),

                  SizedBox(height: context.r(14)),

                  // ── Year of Study ─────────────────────────────────────────
                  _animatedField(
                    delay: 360,
                    child: _DropdownField(
                      hint: 'select_year'.tr(context),
                      value: _selectedYear,
                      icon: Icons.calendar_today_outlined,
                      items: _years,
                      onChanged: (v) => setState(() => _selectedYear = v),
                    ),
                  ),

                  SizedBox(height: context.r(32)),

                  // ── Save Button ───────────────────────────────────────────
                  AppAnimations.combined(
                    type: CombineType.fadeSlide,
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 420),
                    direction: SlideDirection.up,
                    slideDistance: 16,
                    child:
                        BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
                      builder: (_, state) => CustomButton(
                        label: 'save_and_continue'.tr(context),
                        onTap: _onSave,
                        isLoading: state is CompleteProfileLoading,
                      ),
                    ),
                  ),

                  SizedBox(height: context.r(16)),

                  // ── Skip ──────────────────────────────────────────────────
                  AppAnimations.fade(
                    duration: AppDurations.short,
                    delay: const Duration(milliseconds: 480),
                    child: TextButton(
                      onPressed: () => Navigation.offAllNamed(AppRoutes.home),
                      child: Text('skip_for_now'.tr(context)),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedField({required int delay, required Widget child}) =>
      AppAnimations.combined(
        type: CombineType.fadeSlide,
        duration: AppDurations.short,
        delay: Duration(milliseconds: delay),
        direction: SlideDirection.up,
        slideDistance: 18,
        child: child,
      );
}

// ── Reusable dropdown field ───────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final IconData icon;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45))),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor,
        enabledBorder: inputTheme.enabledBorder,
        focusedBorder: inputTheme.focusedBorder,
        border: inputTheme.border,
        contentPadding: inputTheme.contentPadding,
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      dropdownColor: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(12),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
