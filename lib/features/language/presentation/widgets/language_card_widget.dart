// lib/features/language/presentation/widgets/language_card_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LanguageCardWidget extends StatelessWidget {
  final String code, label, nativeLabel, flagEmoji;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCardWidget({
    super.key,
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flagEmoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(flagEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nativeLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  width: 2),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: AppColors.white, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }
}
