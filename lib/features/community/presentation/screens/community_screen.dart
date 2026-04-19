// lib/features/community/presentation/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/error_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/community/data/models/post_model.dart';
import 'package:section/features/community/data/repositories/community_repository.dart';
import 'package:section/features/community/presentation/cubit/community_cubit.dart';
import 'package:section/features/community/presentation/cubit/community_state.dart';
import 'package:section/features/community/presentation/screens/create_post_screen.dart';
import 'package:section/features/community/presentation/screens/post_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CommunityCubit(CommunityRepository()),
    child: const _CommunityView(),
  );
}

class _CommunityView extends StatefulWidget {
  const _CommunityView();
  @override State<_CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<_CommunityView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300) {
        context.read<CommunityCubit>().loadMore();
      }
    });
    _loadWithFaculty();
  }

  Future<void> _loadWithFaculty() async {
    final uid = SupabaseService.currentUserId;
    String? faculty;
    if (uid != null) {
      final p = await SupabaseService.client.from('profiles').select('faculty').eq('id', uid).maybeSingle();
      faculty = p?['faculty'] as String?;
    }
    if (mounted) context.read<CommunityCubit>().init(faculty: faculty);
  }

  @override
  void dispose() { _tabCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'المجتمع' : 'Community',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
          actions: [
            IconButton(icon: const Icon(Icons.chat_outlined), onPressed: () {}),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            onTap: (i) => ctx.read<CommunityCubit>().switchTab(i),
            tabs: [Tab(text: isAr ? 'الكل' : 'Global'), Tab(text: isAr ? 'كليتي' : 'My Faculty')],
          ),
        ),
        body: switch (state.status) {
          CommunityStatus.loading => ListView.builder(itemCount: 4,
            itemBuilder: (_, __) => const Padding(padding: EdgeInsets.fromLTRB(16,6,16,0), child: ShimmerWidget(height: 150, borderRadius: 16))),
          CommunityStatus.error => ErrorStateWidget(message: state.error ?? 'Error', onRetry: () => ctx.read<CommunityCubit>().load()),
          _ => RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: () => ctx.read<CommunityCubit>().load(),
              child: state.posts.isEmpty
                ? Center(child: Text(isAr ? 'لا توجد منشورات بعد' : 'No posts yet', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight)))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.posts.length + (state.status == CommunityStatus.loadingMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == state.posts.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppColors.secondary)));
                      final post = state.posts[i];
                      return _PostCard(post: post, isAr: isAr,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
                        onUpvote: () { HapticFeedback.lightImpact(); ctx.read<CommunityCubit>().toggleUpvote(post.id); });
                    }),
            ),
        },
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () async {
            final newPost = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
            if (newPost != null && mounted) ctx.read<CommunityCubit>().addPost(newPost);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post; final bool isAr;
  final VoidCallback onTap, onUpvote;
  const _PostCard({required this.post, required this.isAr, required this.onTap, required this.onUpvote});

  Color get _borderColor {
    switch(post.postType) {
      case 'question': return const Color(0xFFFFAB00);
      case 'experience': return AppColors.success;
      case 'announcement': return AppColors.error;
      default: return AppColors.info;
    }
  }

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
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            Container(width: 4, decoration: BoxDecoration(color: _borderColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
            Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Author
              Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.backgroundLight,
                  backgroundImage: post.userAvatarUrl != null ? NetworkImage(post.userAvatarUrl!) : null,
                  child: post.userAvatarUrl == null ? const Icon(Icons.person, size: 16, color: AppColors.dividerLight) : null),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(post.userFullName ?? (isAr ? 'مجهول' : 'Anonymous'),
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13)),
                    if (post.userIsVerified) ...[const SizedBox(width: 4), const Icon(Icons.verified_rounded, size: 13, color: AppColors.info)],
                  ]),
                  Text(timeago.format(post.createdAt, locale: isAr ? 'ar' : 'en'),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _borderColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(_typeLabel(isAr), style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w700, color: _borderColor))),
              ]),
              const SizedBox(height: 10),
              Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(post.body, maxLines: 3, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondaryLight, height: 1.5)),
              const SizedBox(height: 10),
              Row(children: [
                GestureDetector(onTap: onUpvote, child: Row(children: [
                  Icon(post.isUpvotedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                    size: 17, color: post.isUpvotedByMe ? AppColors.secondary : AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text('${post.upvoteCount}', style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                    color: post.isUpvotedByMe ? AppColors.secondary : AppColors.textSecondaryLight)),
                ])),
                const SizedBox(width: 16),
                Row(children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondaryLight)),
                ]),
              ]),
            ]))),
          ]),
        ),
      ),
    );
  }

  String _typeLabel(bool isAr) {
    switch(post.postType) {
      case 'question': return isAr ? 'سؤال' : 'Question';
      case 'experience': return isAr ? 'تجربة' : 'Experience';
      case 'announcement': return isAr ? 'إعلان' : 'Announcement';
      default: return isAr ? 'نقاش' : 'Discussion';
    }
  }
}
