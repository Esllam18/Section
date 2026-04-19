class ChatMessageModel {
  final String id, conversationId, senderId, body;
  final String? senderName, senderAvatarUrl, fileUrl;
  final bool isRead; final DateTime createdAt;
  const ChatMessageModel({required this.id,required this.conversationId,
    required this.senderId,required this.body,this.senderName,
    this.senderAvatarUrl,this.fileUrl,this.isRead=false,required this.createdAt});
  factory ChatMessageModel.fromJson(Map<String,dynamic> j) {
    final s = j['sender'] as Map<String,dynamic>?;
    return ChatMessageModel(id:j['id'],conversationId:j['conversation_id'],
      senderId:j['sender_id'],body:j['body']??'',
      senderName:s?['full_name'],senderAvatarUrl:s?['avatar_url'],
      fileUrl:j['file_url'],isRead:j['is_read']??false,
      createdAt:DateTime.parse(j['created_at']));
  }
}
