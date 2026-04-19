// lib/features/home/widgets/home_stats_row.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class HomeStatsRow extends StatelessWidget {
  final int cartCount;
  final int subjectCount;
  final int resourceCount;
  final bool isAr;

  const HomeStatsRow({
    super.key,
    required this.cartCount,
    required this.subjectCount,
    required this.resourceCount,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _StatCard(
          value: '$cartCount',
          label: isAr ? 'في السلة' : 'In cart',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.primary,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '$subjectCount',
          label: isAr ? 'مادة' : 'Subjects',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF7B1FA2),
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '$resourceCount',
          label: isAr ? 'مصدر' : 'Resources',
          icon: Icons.file_present_outlined,
          color: AppColors.secondary,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
