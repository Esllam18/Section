// lib/features/complete_profile/presentation/widgets/profile_dropdown.dart
import 'package:flutter/material.dart';

class ProfileDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final IconData icon;
  final List<String> items;
  final void Function(String?) onChanged;

  const ProfileDropdown(
      {super.key,
      required this.hint,
      this.value,
      required this.icon,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = theme.inputDecorationTheme;
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4))),
      decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          filled: input.filled,
          fillColor: input.fillColor,
          enabledBorder: input.enabledBorder,
          focusedBorder: input.focusedBorder,
          border: input.border,
          contentPadding: input.contentPadding),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: theme.colorScheme.onSurface.withOpacity(0.4)),
      dropdownColor: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(14),
      items: items
          .map((e) => DropdownMenuItem(
              value: e, child: Text(e, style: theme.textTheme.bodyMedium)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
