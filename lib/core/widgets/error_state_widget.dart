import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/widgets/custom_button.dart';
class ErrorStateWidget extends StatelessWidget {
  final String message; final VoidCallback? onRetry;
  const ErrorStateWidget({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 64),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight)),
        if (onRetry != null) ...[const SizedBox(height: 24),
          CustomButton(label: 'Retry', onTap: onRetry, width: 160, backgroundColor: AppColors.primary)],
      ])));
}
