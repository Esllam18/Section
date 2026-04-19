// lib/core/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SnackType { success, error, warning, info }

abstract final class AppSnackBar {
  static void show(BuildContext context, {required String message,
    SnackType type = SnackType.info, Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Row(children: [
          Icon(_icon(type), color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message,
              style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500))),
        ]),
        backgroundColor: _color(type),
      ));
  }

  static IconData _icon(SnackType t) => switch (t) {
    SnackType.success => Icons.check_circle_rounded,
    SnackType.error   => Icons.error_rounded,
    SnackType.warning => Icons.warning_rounded,
    SnackType.info    => Icons.info_rounded,
  };

  static Color _color(SnackType t) => switch (t) {
    SnackType.success => AppColors.success,
    SnackType.error   => AppColors.error,
    SnackType.warning => AppColors.warning,
    SnackType.info    => AppColors.info,
  };
}
