// lib/features/notifications/presentation/screens/notification_router.dart
import 'package:section/features/notifications/data/models/notification_model.dart';

/// Maps a notification type / FCM payload to an in-app screen.
abstract final class NotificationRouter {
  /// Called from NotificationTile tap and FCM tap handler.
  static void navigate(NotificationModel n) {
    switch (n.type) {
      case NotificationType.order:
        _toOrders();
      case NotificationType.community:
        _toCommunity();
      case NotificationType.study:
        _toStudy();
      case NotificationType.chat:
        _toChat();
      case NotificationType.system:
        break; // No deep link for system
    }
  }

  /// Called from FCM payload string (e.g. "orders", "chat", "study").
  static void navigateFromPayload(String? payload) {
    if (payload == null) return;
    if (payload.startsWith('order')) return _toOrders();
    if (payload == 'chat') return _toCommunity();
    if (payload == 'study') return _toStudy();
    if (payload == 'community') return _toCommunity();
  }

  // ── Lazy imports to avoid circular deps ──────────────────────────────────
  static void _toOrders() {
    // Navigation.to(const OrdersScreen());  // Day 5
  }

  static void _toCommunity() {
    // Navigation.to(const CommunityScreen());  // Day 6
  }

  static void _toStudy() {
    // Navigation.to(const StudyScreen());  // Day 7
  }

  static void _toChat() {
    // Navigation.to(const ChatListScreen());  // Day 6
  }
}
