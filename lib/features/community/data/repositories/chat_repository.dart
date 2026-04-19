import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/features/community/data/models/chat_conversation_model.dart';
import 'package:section/features/community/data/models/chat_message_model.dart';

class ChatRepository {
  final _db = Supabase.instance.client;
  RealtimeChannel? _channel;

  String get _uid => _db.auth.currentUser?.id ?? '';

  Future<List<ChatConversationModel>> getConversations() async {
    if (_uid.isEmpty) return [];
    final d = await _db
        .from('chat_conversations')
        .select(
            '*,participant_one_profile:profiles!participant_one(id,full_name,avatar_url),'
            'participant_two_profile:profiles!participant_two(id,full_name,avatar_url)')
        .or('participant_one.eq.$_uid,participant_two.eq.$_uid')
        .order('last_message_at', ascending: false);
    return (d as List<dynamic>)
        .map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages(String convId) async {
    final d = await _db
        .from('chat_messages')
        .select('*,sender:profiles!sender_id(id,full_name,avatar_url)')
        .eq('conversation_id', convId)
        .order('created_at')
        .limit(60);
    return (d as List<dynamic>)
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessageModel> sendMessage(
      {required String convId, required String body}) async {
    final d = await _db
        .from('chat_messages')
        .insert({'conversation_id': convId, 'sender_id': _uid, 'body': body})
        .select()
        .single();
    await _db
        .from('chat_conversations')
        .update({
          'last_message': body,
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .eq('id', convId);
    return ChatMessageModel.fromJson(d);
  }

  void subscribe(String convId, void Function(ChatMessageModel) cb) {
    _channel = _db
        .channel('chat:$convId')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'conversation_id',
                value: convId),
            callback: (p) =>
                cb(ChatMessageModel.fromJson(p.newRecord)))
        .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<ChatConversationModel> startConversation(String otherId) async {
    final myId = _uid;
    if (myId.isEmpty) throw Exception('Not authenticated');
    final ex = await _db
        .from('chat_conversations')
        .select()
        .or('and(participant_one.eq.$myId,participant_two.eq.$otherId),'
            'and(participant_one.eq.$otherId,participant_two.eq.$myId)')
        .maybeSingle();
    if (ex != null) return ChatConversationModel.fromJson(ex);
    final c = await _db
        .from('chat_conversations')
        .insert({'participant_one': myId, 'participant_two': otherId})
        .select()
        .single();
    return ChatConversationModel.fromJson(c);
  }
}
