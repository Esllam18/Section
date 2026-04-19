// lib/features/home/widgets/home_profile_nudge.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/features/profile_setup/presentation/screens/profile_setup_screen.dart';

class HomeProfileNudge extends StatelessWidget {
  final bool isAr;
  const HomeProfileNudge({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigation.to(const ProfileSetupScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'أكمل ملفك الشخصي' : 'Complete your profile',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'حتى نخصص المحتوى لك'
                        : 'So we can personalise your experience',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.warning.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.warning.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
