import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:section/core/constants/app_assets.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/widgets/custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title; final String? subtitle;
  final String lottie; final String? actionLabel; final VoidCallback? onAction;
  const EmptyStateWidget({super.key, required this.title, this.subtitle,
    this.lottie = AppAssets.lottieEmpty, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Lottie.asset(lottie, width: 180, height: 180),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
        if (subtitle != null) ...[const SizedBox(height: 8),
          Text(subtitle!, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight))],
        if (actionLabel != null && onAction != null) ...[const SizedBox(height: 24),
          CustomButton(label: actionLabel!, onTap: onAction, useGradient: true, width: 200)],
      ])));
}
