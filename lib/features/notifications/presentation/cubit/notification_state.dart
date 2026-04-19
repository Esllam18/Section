// lib/features/notifications/presentation/cubit/notification_state.dart
import 'package:equatable/equatable.dart';
import 'package:section/features/notifications/data/models/notification_model.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  @override List<Object?> get props => [];
}

final class NotificationInitial  extends NotificationState {}
final class NotificationLoading  extends NotificationState {}
final class NotificationError    extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override List<Object?> get props => [message];
}
final class NotificationLoaded extends NotificationState {
  final List<NotificationModel> items;
  final int unreadCount;
  const NotificationLoaded({required this.items, required this.unreadCount});
  @override List<Object?> get props => [items, unreadCount];

  bool get hasUnread => unreadCount > 0;
}
