// lib/features/splash/presentation/widgets/splash_bg.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SplashBg extends StatefulWidget {
  const SplashBg({super.key});
  @override State<SplashBg> createState() => _SplashBgState();
}

class _SplashBgState extends State<SplashBg> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.sizeOf(context);
    return AnimatedBuilder(animation: _ctrl,
      builder: (_, __) => CustomPaint(size: sz, painter: _OrbPainter(_ctrl.value)));
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = AppColors.darkBg);

    _orb(canvas, Offset(w * (0.12 + 0.12 * math.sin(t * math.pi * 2)),
        h * (0.18 + 0.08 * math.cos(t * math.pi * 2 * 0.7))),
        w * 0.58, AppColors.primary.withOpacity(0.38));

    _orb(canvas, Offset(w * (0.88 + 0.07 * math.cos(t * math.pi * 2 * 0.6)),
        h * (0.78 + 0.09 * math.sin(t * math.pi * 2 * 0.9))),
        w * 0.52, AppColors.accent.withOpacity(0.30));

    _orb(canvas, Offset(w * (0.5 + 0.04 * math.sin(t * math.pi * 2 * 1.3)),
        h * (0.46 + 0.05 * math.cos(t * math.pi * 2 * 0.8))),
        w * 0.32, AppColors.primaryLight.withOpacity(0.13));
  }

  void _orb(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(center, radius, Paint()
      ..shader = RadialGradient(colors: [color, color.withOpacity(0)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.screen);
  }

  @override bool shouldRepaint(covariant _OrbPainter o) => o.t != t;
}
