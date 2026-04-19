// lib/core/widgets/section_logo.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SectionLogo extends StatelessWidget {
  final double size;
  final Color? bgColor;
  final Color? crossColor;
  const SectionLogo({super.key, this.size = 64, this.bgColor, this.crossColor});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: bgColor ?? AppColors.white, shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.22),
          blurRadius: size * 0.4, offset: Offset(0, size * 0.1))]),
    child: Center(child: CustomPaint(size: Size(size * 0.44, size * 0.44),
        painter: _CrossPainter(crossColor ?? AppColors.primary))),
  );
}

class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final t = size.width / 3;
    final r = Radius.circular(t * 0.45);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, t, size.width, t), r), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(t, 0, t, size.height), r), p);
  }
  @override bool shouldRepaint(covariant _CrossPainter o) => o.color != color;
}
