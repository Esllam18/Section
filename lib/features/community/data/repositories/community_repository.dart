import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/features/community/data/models/comment_model.dart';
import 'package:section/features/community/data/models/post_model.dart';

class CommunityRepository {
  final _db = Supabase.instance.client;

  Future<List<PostModel>> getPosts({String? faculty, int page = 0}) async {
    // Filters first, then order/range
    var q = _db
        .from('community_posts')
        .select('*,profiles(id,full_name,avatar_url,is_verified)');
    if (faculty != null) q = q.eq('faculty', faculty);
    final data = await q
        .order('created_at', ascending: false)
        .range(page * 20, (page + 1) * 20 - 1);
    return (data as List<dynamic>)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PostModel> getPostById(String id) async => PostModel.fromJson(await _db
      .from('community_posts')
      .select('*,profiles(id,full_name,avatar_url,is_verified)')
      .eq('id', id)
      .single());

  Future<PostModel> createPost({
    required String title,
    required String body,
    required String postType,
    String? faculty,
  }) async {
    final uid = _db.auth.currentUser!.id;
    final d = await _db
        .from('community_posts')
        .insert({
          'user_id': uid,
          'post_type': postType,
          'title': title,
          'body': body,
          'images': [],
          'faculty': faculty,
        })
        .select('*,profiles(id,full_name,avatar_url,is_verified)')
        .single();
    return PostModel.fromJson(d);
  }

  Future<List<CommentModel>> getComments(String postId) async => (await _db
          .from('post_comments')
          .select('*,profiles(id,full_name,avatar_url)')
          .eq('post_id', postId)
          .order('created_at'))
      .map((e) => CommentModel.fromJson(e))
      .toList();

  Future<CommentModel> addComment({
    required String postId,
    required String body,
    String? parentId,
  }) async {
    final uid = _db.auth.currentUser!.id;
    final d = await _db
        .from('post_comments')
        .insert({
          'post_id': postId,
          'user_id': uid,
          'body': body,
          'parent_id': parentId
        })
        .select('*,profiles(id,full_name,avatar_url)')
        .single();
    return CommentModel.fromJson(d);
  }

  Future<void> toggleUpvote(String postId) async {
    final uid = _db.auth.currentUser!.id;
    final ex = await _db
        .from('post_upvotes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();
    if (ex != null) {
      await _db.from('post_upvotes').delete().eq('id', ex['id']);
    } else {
      await _db
          .from('post_upvotes')
          .insert({'post_id': postId, 'user_id': uid});
    }
  }
}
