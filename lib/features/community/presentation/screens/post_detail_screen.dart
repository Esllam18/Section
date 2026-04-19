import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/community/data/models/post_model.dart';
import 'package:section/features/community/data/models/comment_model.dart';
import 'package:section/features/community/data/repositories/community_repository.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});
  @override State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post; List<CommentModel> _comments = [];
  bool _loading = true; bool _sending = false;
  final _ctrl = TextEditingController();
  final _repo = CommunityRepository();
  String? _replyToId, _replyToName;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final post = await _repo.getPostById(widget.postId);
      final comments = await _repo.getComments(widget.postId);
      if (mounted) setState(() { _post = post; _comments = comments; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _sendComment(bool isAr) async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      final c = await _repo.addComment(postId: widget.postId, body: _ctrl.text.trim(), parentId: _replyToId);
      setState(() { _comments.add(c); _ctrl.clear(); _replyToId = null; _replyToName = null; _sending = false; });
    } catch (_) { setState(() => _sending = false); }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_loading) return const Scaffold(body: LoadingWidget());
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back),
        title: Text(isAr ? 'المنشور' : 'Post', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600))),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_post != null) ...[
            Text(_post!.title, style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22)),
            const SizedBox(height: 12),
            Row(children: [
              CircleAvatar(radius: 18, backgroundImage: _post!.userAvatarUrl != null ? NetworkImage(_post!.userAvatarUrl!) : null,
                child: _post!.userAvatarUrl == null ? const Icon(Icons.person, size: 18) : null),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_post!.userFullName ?? 'Anonymous', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13)),
                Text(timeago.format(_post!.createdAt, locale: isAr ? 'ar' : 'en'),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
              ]),
            ]),
            const SizedBox(height: 14),
            Text(_post!.body, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, height: 1.7, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            Row(children: [
              GestureDetector(onTap: () {
                HapticFeedback.lightImpact();
                _repo.toggleUpvote(_post!.id);
                setState(() {
                  final was = _post!.isUpvotedByMe;
                  _post = _post!.copyWith(upvoteCount: was ? _post!.upvoteCount-1 : _post!.upvoteCount+1, isUpvotedByMe: !was);
                });
              }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _post!.isUpvotedByMe ? AppColors.secondary.withOpacity(0.1) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _post!.isUpvotedByMe ? AppColors.secondary : AppColors.dividerLight)),
                child: Row(children: [
                  Icon(_post!.isUpvotedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                    size: 16, color: _post!.isUpvotedByMe ? AppColors.secondary : AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Text('${_post!.upvoteCount}', style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                    color: _post!.isUpvotedByMe ? AppColors.secondary : AppColors.textSecondaryLight)),
                ]))),
            ]),
            const Divider(height: 28),
            Text('${isAr ? "التعليقات" : "Comments"} (${_comments.length})',
              style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
          ],
          ..._comments.map((c) => Padding(
            padding: EdgeInsets.only(left: c.parentId != null ? 28 : 0, bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 14, backgroundImage: c.userAvatarUrl != null ? NetworkImage(c.userAvatarUrl!) : null,
                child: c.userAvatarUrl == null ? const Icon(Icons.person, size: 14) : null),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.userFullName ?? 'Anonymous', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(c.body, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5)),
                  ])),
                const SizedBox(height: 3),
                Row(children: [
                  Text(timeago.format(c.createdAt, locale: isAr ? 'ar' : 'en'),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textSecondaryLight)),
                  const SizedBox(width: 12),
                  GestureDetector(onTap: () => setState(() { _replyToId = c.id; _replyToName = c.userFullName; }),
                    child: Text(isAr ? 'رد' : 'Reply', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                ]),
              ])),
            ]))),
        ])),
        if (_replyToName != null) Container(
          color: AppColors.secondary.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            const Icon(Icons.reply_rounded, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Expanded(child: Text('${isAr ? "رد على" : "Replying to"} $_replyToName',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.secondary))),
            GestureDetector(onTap: () => setState(() { _replyToId = null; _replyToName = null; }),
              child: const Icon(Icons.close, size: 16, color: AppColors.secondary)),
          ])),
        SafeArea(child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5))),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: InputDecoration(hintText: isAr ? 'اكتب تعليقاً...' : 'Write a comment...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.dividerLight)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.dividerLight)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), isDense: true))),
            const SizedBox(width: 8),
            GestureDetector(onTap: _sending ? null : () => _sendComment(isAr),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                child: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
          ]))),
      ]),
    );
  }
}
