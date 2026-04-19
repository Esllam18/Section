// lib/features/community/presentation/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:section/core/constants/app_colors.dart';
import 'package:section/features/community/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isAr;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  const PostCard({
    super.key,
    required this.post,
    required this.isAr,
    required this.onTap,
    required this.onUpvote,
  });

  Color get _typeColor => switch (post.postType) {
        'question'     => const Color(0xFFFFAB00),
        'experience'   => AppColors.success,
        'announcement' => AppColors.error,
        _              => AppColors.info,
      };

  String _typeLabel(bool isAr) => switch (post.postType) {
        'question'     => isAr ? 'سؤال'  : 'Question',
        'experience'   => isAr ? 'تجربة' : 'Experience',
        'announcement' => isAr ? 'إعلان' : 'Announcement',
        _              => isAr ? 'نقاش'  : 'Discussion',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Type accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _typeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AuthorRow(post: post, isAr: isAr, typeColor: _typeColor,
                          typeLabel: _typeLabel(isAr)),
                      const SizedBox(height: 10),
                      Text(post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 4),
                      Text(post.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                            height: 1.5,
                          )),
                      const SizedBox(height: 10),
                      _ActionsRow(post: post, isAr: isAr, onUpvote: onUpvote),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final PostModel post;
  final bool isAr;
  final Color typeColor;
  final String typeLabel;

  const _AuthorRow({
    required this.post,
    required this.isAr,
    required this.typeColor,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.backgroundLight,
        backgroundImage: post.userAvatarUrl != null
            ? NetworkImage(post.userAvatarUrl!)
            : null,
        child: post.userAvatarUrl == null
            ? const Icon(Icons.person, size: 16, color: AppColors.dividerLight)
            : null,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(
              post.userFullName ?? (isAr ? 'مجهول' : 'Anonymous'),
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
            if (post.userIsVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified_rounded,
                  size: 13, color: AppColors.info),
            ],
          ]),
          Text(
            timeago.format(post.createdAt, locale: isAr ? 'ar' : 'en'),
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondaryLight),
          ),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(typeLabel,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: typeColor)),
      ),
    ]);
  }
}

class _ActionsRow extends StatelessWidget {
  final PostModel post;
  final bool isAr;
  final VoidCallback onUpvote;
  const _ActionsRow(
      {required this.post, required this.isAr, required this.onUpvote});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onUpvote(); },
        child: Row(children: [
          Icon(
            post.isUpvotedByMe
                ? Icons.thumb_up_rounded
                : Icons.thumb_up_outlined,
            size: 17,
            color: post.isUpvotedByMe
                ? AppColors.secondary
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text('${post.upvoteCount}',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: post.isUpvotedByMe
                      ? AppColors.secondary
                      : AppColors.textSecondaryLight)),
        ]),
      ),
      const SizedBox(width: 16),
      Row(children: [
        const Icon(Icons.chat_bubble_outline_rounded,
            size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text('${post.commentCount}',
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textSecondaryLight)),
      ]),
    ]);
  }
}
