// lib/features/home/widgets/home_recent_posts.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/features/home/data/models/home_summary_model.dart';

class HomeRecentPosts extends StatelessWidget {
  final List<RecentPostSummary> posts;
  final bool isAr;

  const HomeRecentPosts({
    super.key,
    required this.posts,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'من المجتمع' : 'From the Community',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {}, // wired Day 6
              child: Text(
                isAr ? 'الكل' : 'See all',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...posts.map((p) => _PostRow(post: p, isAr: isAr, isDark: isDark)),
      ],
    );
  }
}

class _PostRow extends StatelessWidget {
  final RecentPostSummary post;
  final bool isAr;
  final bool isDark;

  const _PostRow({
    required this.post,
    required this.isAr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final (typeColor, typeLabel) = _typeStyle(post.postType, isAr);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            post.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.thumb_up_outlined,
                  size: 13, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                '${post.upvoteCount}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.comment_outlined,
                  size: 13, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                '${post.commentCount}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, String) _typeStyle(String type, bool isAr) => switch (type) {
        'question'     => (AppColors.primary,   isAr ? 'سؤال'       : 'Question'),
        'experience'   => (AppColors.success,   isAr ? 'تجربة'       : 'Experience'),
        'announcement' => (AppColors.warning,   isAr ? 'إعلان'       : 'Announcement'),
        _              => (AppColors.secondary, isAr ? 'نقاش'        : 'Discussion'),
      };
}
