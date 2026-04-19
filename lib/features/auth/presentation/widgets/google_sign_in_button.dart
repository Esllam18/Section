// lib/features/auth/presentation/widgets/google_sign_in_button.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String label;
  const GoogleSignInButton({super.key, this.onTap, this.isLoading = false,
    this.label = 'Continue with Google'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: (isLoading || onTap == null) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.grey200, width: 0.9),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2,
                    color: theme.colorScheme.primary, strokeCap: StrokeCap.round))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  // Google G logo via network (lightweight)
                  Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 20, height: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded,
                      size: 24, color: Color(0xFF4285F4)),
                  ),
                  const SizedBox(width: 12),
                  Text(label, style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
                ]),
        ),
      ),
    );
  }
}
