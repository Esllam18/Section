// lib/features/complete_profile/presentation/widgets/avatar_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AvatarPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const AvatarPicker({super.key, this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(onTap: onTap,
      child: Stack(children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25), width: 2),
            image: image != null ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover) : null),
          child: image == null ? Icon(Icons.person_rounded, size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5)) : null),
        Positioned(bottom: 0, right: 0,
          child: Container(width: 30, height: 30,
            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)),
            child: const Icon(Icons.camera_alt_rounded, size: 15, color: AppColors.white))),
      ]),
    );
  }
}
