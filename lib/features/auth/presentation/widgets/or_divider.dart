// lib/features/auth/presentation/widgets/or_divider.dart
import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String? label;
  const OrDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline.withOpacity(0.35);
    return Row(children: [
      Expanded(child: Divider(color: color, thickness: 0.8)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(label ?? 'or', style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.4)))),
      Expanded(child: Divider(color: color, thickness: 0.8)),
    ]);
  }
}
