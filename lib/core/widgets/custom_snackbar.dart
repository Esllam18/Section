import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation_service.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show({required String message, SnackBarType type = SnackBarType.info, Duration duration = const Duration(seconds: 3)}) {
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;
    Color bg; IconData icon;
    switch (type) {
      case SnackBarType.success: bg = AppColors.success; icon = Icons.check_circle_outline; break;
      case SnackBarType.error:   bg = AppColors.error;   icon = Icons.error_outline;        break;
      case SnackBarType.warning: bg = AppColors.warning; icon = Icons.warning_amber_outlined; break;
      case SnackBarType.info:    bg = AppColors.info;    icon = Icons.info_outline;           break;
    }
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: bg, duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
