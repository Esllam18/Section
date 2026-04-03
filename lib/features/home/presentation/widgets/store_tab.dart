// lib/features/home/presentation/widgets/store_tab.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoreTab extends StatelessWidget {
  const StoreTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.storefront_rounded, size: 72,
              color: AppColors.primary.withValues(alpha: 0.22)),
          const SizedBox(height: 16),
          Text('Coming in Phase 2',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
        ]),
      ),
    );
  }
}
