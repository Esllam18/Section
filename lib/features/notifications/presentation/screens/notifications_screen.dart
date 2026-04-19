// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>>? _notifs;
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) { setState(() => _loading = false); return; }
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);
      if (mounted) setState(() { _notifs = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _markAllRead() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid);
    setState(() {
      _notifs = _notifs?.map((n) => {...n, 'is_read': true}).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final unreadCount = _notifs?.where((n) => n['is_read'] != true).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back),
        title: Text(isAr ? 'الإشعارات' : 'Notifications',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(isAr ? 'قراءة الكل' : 'Mark all read',
                style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
        ? ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShimmerWidget(height: 72, borderRadius: 12),
            ),
          )
        : _notifs == null || _notifs!.isEmpty
          ? EmptyStateWidget(
              title: isAr ? 'لا توجد إشعارات' : 'No Notifications',
              subtitle: isAr ? 'ستظهر الإشعارات هنا' : 'Notifications will appear here',
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifs!.length,
                itemBuilder: (_, i) => _NotifTile(notif: _notifs![i], isAr: isAr,
                  onTap: () async {
                    // Mark single as read
                    await SupabaseService.client
                        .from('notifications')
                        .update({'is_read': true})
                        .eq('id', _notifs![i]['id']);
                    setState(() => _notifs![i] = {..._notifs![i], 'is_read': true});
                  }),
              ),
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final Map<String, dynamic> notif; final bool isAr; final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.isAr, required this.onTap});

  IconData get _icon {
    switch (notif['type']) {
      case 'order': return Icons.shopping_bag_outlined;
      case 'community': return Icons.people_outline;
      case 'study': return Icons.menu_book_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (notif['type']) {
      case 'order': return AppColors.primary;
      case 'community': return const Color(0xFF7C4DFF);
      case 'study': return AppColors.success;
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = notif['is_read'] == true;
    final createdAt = DateTime.tryParse(notif['created_at'] ?? '') ?? DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? AppColors.cardDark : AppColors.surfaceLight)
              : (isDark ? AppColors.primary.withOpacity(0.12) : AppColors.primary.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? (isDark ? AppColors.dividerDark : AppColors.dividerLight)
                : AppColors.primary.withOpacity(0.25),
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notif['title'] ?? '',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 3),
            Text(notif['body'] ?? '',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondaryLight),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(timeago.format(createdAt, locale: isAr ? 'ar' : 'en'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
          ])),
          if (!isRead)
            Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}
