// lib/features/community/presentation/widgets/post_type_filter.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class PostTypeFilter extends StatelessWidget {
  final String? selectedType;
  final bool isAr;
  final ValueChanged<String?> onChanged;

  const PostTypeFilter({
    super.key,
    required this.selectedType,
    required this.isAr,
    required this.onChanged,
  });

  static const _types = [
    (null,       'الكل',   'All',          AppColors.secondary),
    ('question', 'سؤال',  'Question',     Color(0xFFFFAB00)),
    ('discussion','نقاش',  'Discussion',   AppColors.info),
    ('experience','تجربة', 'Experience',   AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: _types.map((t) {
          final sel = selectedType == t.$1;
          return GestureDetector(
            onTap: () => onChanged(t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? t.$4.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? t.$4 : AppColors.dividerLight,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Text(
                isAr ? t.$2 : t.$3,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? t.$4 : AppColors.textSecondaryLight,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
