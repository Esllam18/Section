// lib/features/auth/presentation/widgets/auth_header.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      SectionLogo(
          size: 62,
          bgColor: theme.colorScheme.primary.withOpacity(0.1),
          crossColor: theme.colorScheme.primary),
      const SizedBox(height: 8),
      Text(AppStrings.appName,
          style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 3.5,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 22),
      Text(title,
          style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55)),
          textAlign: TextAlign.center),
    ]);
  }
}
