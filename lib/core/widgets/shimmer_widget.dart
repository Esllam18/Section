import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:section/core/constants/app_colors.dart';
class ShimmerWidget extends StatelessWidget {
  final double width; final double height; final double borderRadius;
  const ShimmerWidget({super.key, this.width = double.infinity, required this.height, this.borderRadius = 8});
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE0E8F5),
      highlightColor: isDark ? AppColors.dividerDark : const Color(0xFFF5F8FF),
      child: Container(width: width, height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius))));
  }
}
