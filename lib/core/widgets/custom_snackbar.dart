// lib/core/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SnackBarType { success, error, warning, info }

abstract final class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? customIcon,
    Color? customColor,
    SnackBarAction? action,
  }) {
    final color = customColor ?? _color(type);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withValues(alpha: 0.93),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Row(children: [
          Icon(customIcon ?? _icon(type), color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
        action: action,
      ));
  }

  static IconData _icon(SnackBarType t) => switch (t) {
        SnackBarType.success => Icons.check_circle_rounded,
        SnackBarType.error   => Icons.error_rounded,
        SnackBarType.warning => Icons.warning_rounded,
        SnackBarType.info    => Icons.info_rounded,
      };

  static Color _color(SnackBarType t) => switch (t) {
        SnackBarType.success => AppColors.success,
        SnackBarType.error   => AppColors.error,
        SnackBarType.warning => AppColors.warning,
        SnackBarType.info    => AppColors.info,
      };
}
