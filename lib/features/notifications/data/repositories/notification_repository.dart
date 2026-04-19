// lib/features/notifications/data/repositories/notification_repository.dart
import 'package:section/core/services/supabase_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _client = SupabaseService.client;
  static const _table = 'notifications';

  // ── Fetch all for current user ─────────────────────────────────────────────
  Future<List<NotificationModel>> fetchAll() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);
    return (rows as List).map((r) => NotificationModel.fromJson(r)).toList();
  }

  // ── Unread count ───────────────────────────────────────────────────────────
  Future<int> unreadCount() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return 0;
    final rows = await _client
        .from(_table)
        .select('id')
        .eq('user_id', uid)
        .eq('is_read', false);
    return (rows as List).length;
  }

  // ── Mark one as read ───────────────────────────────────────────────────────
  Future<void> markRead(String id) async {
    await _client.from(_table).update({'is_read': true}).eq('id', id);
  }

  // ── Mark all as read ───────────────────────────────────────────────────────
  Future<void> markAllRead() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }

  // ── Delete one ─────────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  // ── Realtime stream ────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> stream() {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return const Stream.empty();
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);
  }
}
