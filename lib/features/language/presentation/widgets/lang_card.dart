// lib/features/language/presentation/widgets/lang_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LangCard extends StatelessWidget {
  final String code, native, label, emoji;
  final bool selected;
  final VoidCallback onTap;

  const LangCard({super.key, required this.code, required this.native,
    required this.label, required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(isDark ? 0.18 : 0.07) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.4),
            width: selected ? 1.8 : 0.8)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(native, style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45))),
          ])),
          AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.4),
                width: 1.5)),
            child: selected ? const Icon(Icons.check_rounded, color: AppColors.white, size: 13) : null),
        ]),
      ),
    );
  }
}
