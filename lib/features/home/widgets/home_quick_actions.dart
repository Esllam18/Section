// lib/features/home/widgets/home_quick_actions.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class HomeQuickActions extends StatelessWidget {
  final bool isAr;
  const HomeQuickActions({super.key, required this.isAr});

  static const _kActions = [
    _Action(Icons.shopping_bag_outlined,  AppColors.primary,              'Store',     'المتجر'),
    _Action(Icons.people_outline,          Color(0xFF7C4DFF),              'Community', 'المجتمع'),
    _Action(Icons.menu_book_outlined,      AppColors.success,              'Study',     'الدراسة'),
    _Action(Icons.smart_toy_outlined,      AppColors.secondary,            'AI',        'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _kActions
          .map((a) => _ActionTile(action: a, isAr: isAr, isDark: isDark))
          .toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  final bool isAr;
  final bool isDark;

  const _ActionTile({
    required this.action,
    required this.isAr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(action.icon, color: action.color, size: 24),
        ),
        const SizedBox(height: 5),
        Text(
          isAr ? action.labelAr : action.labelEn,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Action {
  final IconData icon;
  final Color color;
  final String labelEn;
  final String labelAr;
  const _Action(this.icon, this.color, this.labelEn, this.labelAr);
}
