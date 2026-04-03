// lib/features/splash/presentation/widgets/animated_logo_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({super.key});
  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.06)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) =>
          Transform.scale(scale: _pulse.value, child: child),
      child: Container(
        width: 114,
        height: 114,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.white.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
                color: AppColors.white, shape: BoxShape.circle),
            child: Center(child: CustomPaint(size: const Size(40, 40), painter: _CrossPainter())),
          ),
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    final t = size.width / 3;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, t, size.width, t), const Radius.circular(4)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(t, 0, t, size.height), const Radius.circular(4)), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
