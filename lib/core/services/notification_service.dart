// lib/core/services/notification_service.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:section/core/services/supabase_service.dart';

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static const _channelId   = 'section_main';
  static const _channelName = 'Section Notifications';

  static Future<void> init({
    Future<void> Function(RemoteMessage)? backgroundHandler,
  }) async {
    // Local notifications setup
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId, _channelName,
        description: 'Section app notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Firebase Cloud Messaging
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    // Background handler
    if (backgroundHandler != null) {
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Save FCM token
    final token = await fcm.getToken();
    if (token != null) await _saveFcmToken(token);

    // Token refresh
    fcm.onTokenRefresh.listen(_saveFcmToken);
  }

  static void _onTap(NotificationResponse r) {
    debugPrint('Notification tapped: ${r.payload}');
  }

  static Future<void> _handleForeground(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await show(
      title: n.title ?? 'Section',
      body: n.body ?? '',
      payload: message.data['route'],
    );
  }

  static void _handleTap(RemoteMessage message) {
    debugPrint('FCM tap: ${message.data}');
  }

  static Future<void> _saveFcmToken(String token) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    try {
      await SupabaseService.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (_) {}
  }

  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notifications_enabled') ?? true)) return;

    await _local.show(
      id, title, body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF1565C0),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> showOrderUpdate(String orderNum, String status,
      {bool isAr = true}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_order_updates') ?? true)) return;
    await show(
      title: isAr ? 'تحديث طلبك' : 'Order Update',
      body:  isAr ? 'طلب #$orderNum: $status' : 'Order #$orderNum: $status',
      payload: 'order:$orderNum',
    );
  }

  static Future<void> showNewMessage(String sender, String msg,
      {bool isAr = true}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_community_replies') ?? true)) return;
    await show(title: sender, body: msg, payload: 'chat');
  }

  static Future<void> showNewResource(String subject,
      {bool isAr = true}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_new_resources') ?? true)) return;
    await show(
      title: isAr ? 'مصدر جديد' : 'New Resource',
      body:  isAr ? 'تم إضافة مصدر جديد في $subject' : 'New resource in $subject',
      payload: 'study',
    );
  }

  static Future<void> cancelAll() => _local.cancelAll();
}
