// lib/features/notifications/presentation/cubit/notification_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/notifications/data/models/notification_model.dart';
import 'package:section/features/notifications/data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;
  StreamSubscription? _sub;

  NotificationCubit(this._repo) : super(NotificationInitial());

  // ── Initial load + start realtime stream ──────────────────────────────────
  Future<void> load() async {
    emit(NotificationLoading());
    try {
      final items = await _repo.fetchAll();
      final unread = items.where((n) => !n.isRead).length;
      emit(NotificationLoaded(items: items, unreadCount: unread));
      _startStream();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // ── Realtime: push new rows as they arrive ─────────────────────────────────
  void _startStream() {
    _sub?.cancel();
    _sub = _repo.stream().listen((rows) {
      final items = rows.map(NotificationModel.fromJson).toList();
      final unread = items.where((n) => !n.isRead).length;
      if (!isClosed) emit(NotificationLoaded(items: items, unreadCount: unread));
    });
  }

  // ── Mark one notification as read ─────────────────────────────────────────
  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.items
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      final unread = updated.where((n) => !n.isRead).length;
      emit(NotificationLoaded(items: updated, unreadCount: unread));
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllRead() async {
    await _repo.markAllRead();
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.items.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationLoaded(items: updated, unreadCount: 0));
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _repo.delete(id);
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.items.where((n) => n.id != id).toList();
      final unread = updated.where((n) => !n.isRead).length;
      emit(NotificationLoaded(items: updated, unreadCount: unread));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
