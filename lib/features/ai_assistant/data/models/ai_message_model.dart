class AiMessageModel {
  final String id, role, content;
  final DateTime createdAt;
  const AiMessageModel({required this.id, required this.role, required this.content, required this.createdAt});
  bool get isUser => role == 'user';
  Map<String, String> toGroqMessage() => {'role': role, 'content': content};
}
