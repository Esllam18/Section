// lib/features/auth/presentation/widgets/auth_header_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomPaint(
                size: const Size(28, 28), painter: _CrossPainter()),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        Text(title,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    final t = size.width / 3;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, t, size.width, t), const Radius.circular(3)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(t, 0, t, size.height), const Radius.circular(3)), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
