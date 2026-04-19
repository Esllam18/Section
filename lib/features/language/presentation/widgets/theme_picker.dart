// lib/features/language/presentation/widgets/theme_picker.dart
import 'package:flutter/material.dart';

class ThemePicker extends StatelessWidget {
  final ThemeMode selected;
  final bool isAR;
  final void Function(ThemeMode) onChange;

  const ThemePicker({super.key, required this.selected, required this.isAR, required this.onChange});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _Card(icon: Icons.wb_sunny_rounded, label: isAR ? 'فاتح' : 'Light',
      mode: ThemeMode.light, selected: selected == ThemeMode.light, onTap: () => onChange(ThemeMode.light))),
    const SizedBox(width: 10),
    Expanded(child: _Card(icon: Icons.nights_stay_rounded, label: isAR ? 'داكن' : 'Dark',
      mode: ThemeMode.dark, selected: selected == ThemeMode.dark, onTap: () => onChange(ThemeMode.dark))),
    const SizedBox(width: 10),
    Expanded(child: _Card(icon: Icons.auto_mode_rounded, label: isAR ? 'تلقائي' : 'Auto',
      mode: ThemeMode.system, selected: selected == ThemeMode.system, onTap: () => onChange(ThemeMode.system))),
  ]);
}

class _Card extends StatelessWidget {
  final IconData icon; final String label; final ThemeMode mode;
  final bool selected; final VoidCallback onTap;
  const _Card({required this.icon, required this.label, required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(isDark ? 0.18 : 0.08) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.35), width: selected ? 1.8 : 0.8)),
        child: Column(children: [
          Icon(icon, size: 22, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.45)),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}
