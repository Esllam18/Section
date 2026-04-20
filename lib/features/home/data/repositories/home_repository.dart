// lib/features/home/data/repositories/home_repository.dart
import 'package:section/core/services/supabase_service.dart';
import '../models/home_summary_model.dart';

class HomeRepository {
  final _db = SupabaseService.client;

  /// Fetches all home data in parallel — one round trip per query.
  Future<HomeSummaryModel> getSummary() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    // Run all queries concurrently
    final results = await Future.wait([
      _profile(uid),
      _cartCount(uid),
      _unreadNotifs(uid),
      _recentOrders(uid),
      _recentPosts(uid),
      _studyStats(uid),
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final cartCount = results[1] as int;
    final unreadNotifs = results[2] as int;
    final recentOrders = results[3] as List<RecentOrderSummary>;
    final recentPosts = results[4] as List<RecentPostSummary>;
    final studyStats = results[5] as Map<String, int>;

    return HomeSummaryModel(
      fullName: profile['full_name'] as String? ?? '',
      faculty: profile['faculty'] as String? ?? '',
      academicYear: profile['academic_year'] as int? ?? 1,
      isProfileComplete: profile['is_profile_complete'] as bool? ?? false,
      cartCount: cartCount,
      unreadNotifications: unreadNotifs,
      recentOrders: recentOrders,
      recentPosts: recentPosts,
      subjectCount: studyStats['subjects'] ?? 0,
      resourceCount: studyStats['resources'] ?? 0,
    );
  }

  Future<Map<String, dynamic>> _profile(String uid) async {
    final d = await _db
        .from('profiles')
        .select('full_name,faculty,academic_year,is_profile_complete')
        .eq('id', uid)
        .maybeSingle();
    return d ?? {};
  }

  Future<int> _cartCount(String uid) async {
    final d = await _db.from('cart_items').select('id').eq('user_id', uid);
    return (d as List).length;
  }

  Future<int> _unreadNotifs(String uid) async {
    final d = await _db
        .from('notifications')
        .select('id')
        .eq('user_id', uid)
        .eq('is_read', false);
    return (d as List).length;
  }

  Future<List<RecentOrderSummary>> _recentOrders(String uid) async {
    final d = await _db
        .from('orders')
        .select('id,order_number,status,total,created_at')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(3);
    return (d as List)
        .map((e) => RecentOrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecentPostSummary>> _recentPosts(String uid) async {
    final d = await _db
        .from('community_posts')
        .select('id,title,post_type,upvote_count,comment_count,created_at')
        .order('created_at', ascending: false)
        .limit(3);
    return (d as List)
        .map((e) => RecentPostSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> _studyStats(String uid) async {
    // Get faculty from profile first, then count subjects
    try {
      final profile = await _db
          .from('profiles')
          .select('faculty')
          .eq('id', uid)
          .maybeSingle();
      final faculty = profile?['faculty'] as String?;
      if (faculty == null) return {'subjects': 0, 'resources': 0};

      final subjects =
          await _db.from('subjects').select('id').eq('faculty', faculty);
      return {'subjects': (subjects as List).length, 'resources': 0};
    } catch (_) {
      return {'subjects': 0, 'resources': 0};
    }
  }
}
