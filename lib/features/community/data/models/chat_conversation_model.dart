class ChatConversationModel {
  final String id, participantOne, participantTwo;
  final String? p1Name, p1Avatar, p2Name, p2Avatar, lastMessage;
  final DateTime? lastMessageAt;
  const ChatConversationModel({required this.id,required this.participantOne,
    required this.participantTwo,this.p1Name,this.p1Avatar,this.p2Name,this.p2Avatar,
    this.lastMessage,this.lastMessageAt});
  factory ChatConversationModel.fromJson(Map<String,dynamic> j) {
    final p1 = j['participant_one_profile'] as Map<String,dynamic>?;
    final p2 = j['participant_two_profile'] as Map<String,dynamic>?;
    return ChatConversationModel(id:j['id'],participantOne:j['participant_one'],
      participantTwo:j['participant_two'],p1Name:p1?['full_name'],p1Avatar:p1?['avatar_url'],
      p2Name:p2?['full_name'],p2Avatar:p2?['avatar_url'],lastMessage:j['last_message'],
      lastMessageAt:j['last_message_at']!=null?DateTime.parse(j['last_message_at']):null);
  }
  String otherName(String myId) => participantOne==myId?(p2Name??'User'):(p1Name??'User');
  String? otherAvatar(String myId) => participantOne==myId?p2Avatar:p1Avatar;
  String otherId(String myId) => participantOne==myId?participantTwo:participantOne;
}
