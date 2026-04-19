// lib/layout/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAr;
  final int unreadNotifs;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isAr,
    required this.onTap,
    this.unreadNotifs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _Item(Icons.home_outlined,          Icons.home_rounded,           isAr ? 'الرئيسية' : 'Home'),
      _Item(Icons.shopping_bag_outlined,  Icons.shopping_bag_rounded,   isAr ? 'المتجر'   : 'Store'),
      _Item(Icons.people_outline,         Icons.people_rounded,         isAr ? 'المجتمع'  : 'Community'),
      _Item(Icons.menu_book_outlined,     Icons.menu_book_rounded,      isAr ? 'الدراسة'  : 'Study'),
      _Item(Icons.smart_toy_outlined,     Icons.smart_toy_rounded,      isAr ? 'AI'       : 'AI'),
      _Item(Icons.person_outline_rounded, Icons.person_rounded,         isAr ? 'حسابي'    : 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(top: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight, width: 0.5)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final sel = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(clipBehavior: Clip.none, children: [
                      Icon(sel ? item.activeIcon : item.icon, size: 24,
                        color: sel
                          ? (isDark ? AppColors.secondary : AppColors.primary)
                          : AppColors.textSecondaryLight),
                    ]),
                    const SizedBox(height: 3),
                    Text(item.label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel
                        ? (isDark ? AppColors.secondary : AppColors.primary)
                        : AppColors.textSecondaryLight)),
                    const SizedBox(height: 2),
                    AnimatedContainer(duration: const Duration(milliseconds: 250),
                      width: sel ? 18 : 0, height: 3,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(2))),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon, activeIcon;
  final String label;
  const _Item(this.icon, this.activeIcon, this.label);
}
