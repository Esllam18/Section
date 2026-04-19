// lib/features/notifications/data/models/notification_model.dart

enum NotificationType { order, community, study, chat, system }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        type: _parseType(j['type'] as String?),
        referenceId: j['reference_id'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  static NotificationType _parseType(String? t) => switch (t) {
        'order'     => NotificationType.order,
        'community' => NotificationType.community,
        'study'     => NotificationType.study,
        'chat'      => NotificationType.chat,
        _           => NotificationType.system,
      };
}
