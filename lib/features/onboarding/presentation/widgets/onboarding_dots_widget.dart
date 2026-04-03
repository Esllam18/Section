// lib/features/onboarding/presentation/widgets/onboarding_dots_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingDotsWidget extends StatelessWidget {
  final int currentPage, totalPages;
  const OnboardingDotsWidget(
      {super.key, required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == currentPage ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
