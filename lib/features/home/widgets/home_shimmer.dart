// lib/features/home/widgets/home_shimmer.dart
import 'package:flutter/material.dart';
import 'package:section/core/widgets/shimmer_widget.dart';

/// Full-page shimmer shown while home data loads.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          const ShimmerWidget(height: 110, borderRadius: 20),
          const SizedBox(height: 16),
          // Nudge / stats
          const ShimmerWidget(height: 60, borderRadius: 14),
          const SizedBox(height: 16),
          // Stats row
          Row(children: const [
            Expanded(child: ShimmerWidget(height: 80, borderRadius: 14)),
            SizedBox(width: 10),
            Expanded(child: ShimmerWidget(height: 80, borderRadius: 14)),
            SizedBox(width: 10),
            Expanded(child: ShimmerWidget(height: 80, borderRadius: 14)),
          ]),
          const SizedBox(height: 20),
          // Quick actions
          const ShimmerWidget(height: 80, borderRadius: 14),
          const SizedBox(height: 20),
          // Recent orders title + rows
          const ShimmerWidget(width: 140, height: 18, borderRadius: 6),
          const SizedBox(height: 10),
          const ShimmerWidget(height: 56, borderRadius: 12),
          const SizedBox(height: 8),
          const ShimmerWidget(height: 56, borderRadius: 12),
          const SizedBox(height: 20),
          // Community title + rows
          const ShimmerWidget(width: 160, height: 18, borderRadius: 6),
          const SizedBox(height: 10),
          const ShimmerWidget(height: 80, borderRadius: 12),
          const SizedBox(height: 8),
          const ShimmerWidget(height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}
