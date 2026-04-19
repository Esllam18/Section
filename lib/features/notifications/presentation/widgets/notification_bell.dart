// lib/features/notifications/presentation/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/features/notifications/data/repositories/notification_repository.dart';
import 'package:section/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:section/features/notifications/presentation/cubit/notification_state.dart';
import 'package:section/features/notifications/presentation/screens/notifications_screen.dart';

/// Drop into any AppBar.actions — auto-loads unread count.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(NotificationRepository())..load(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (ctx, state) {
          final unread = state is NotificationLoaded ? state.unreadCount : 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigation.to(
                  BlocProvider.value(
                    value: ctx.read<NotificationCubit>(),
                    child: const NotificationsScreen(),
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
