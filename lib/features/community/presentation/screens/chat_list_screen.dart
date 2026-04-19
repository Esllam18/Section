// lib/features/community/presentation/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/community/data/repositories/chat_repository.dart';
import 'package:section/features/community/presentation/cubit/chat_cubit.dart';
import 'package:section/features/community/presentation/cubit/chat_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ChatListCubit(ChatRepository())..load(),
        child: const _ChatListBody(),
      );
}

class _ChatListBody extends StatelessWidget {
  const _ChatListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        final myId = SupabaseService.currentUserId ?? '';
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: Navigation.back,
            ),
            title: Text(
              isAr ? 'الرسائل' : 'Messages',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
          ),
          body: BlocBuilder<ChatListCubit, ChatListState>(
            builder: (ctx, state) => switch (state.status) {
              ChatStatus.loading => const LoadingWidget(),
              ChatStatus.loaded when state.conversations.isEmpty =>
                EmptyStateWidget(
                  title: isAr ? 'لا توجد محادثات' : 'No conversations yet',
                  subtitle: isAr
                      ? 'تواصل مع زملائك من ملفاتهم الشخصية'
                      : 'Start a chat from someone\'s profile',
                ),
              ChatStatus.loaded => RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () => ctx.read<ChatListCubit>().load(),
                  child: ListView.separated(
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) {
                      final conv = state.conversations[i];
                      final name  = conv.otherName(myId);
                      final avatar = conv.otherAvatar(myId);
                      final otherId = conv.otherId(myId);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: avatar != null
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar == null
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary),
                                )
                              : null,
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        subtitle: conv.lastMessage != null
                            ? Text(
                                conv.lastMessage!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight),
                              )
                            : null,
                        trailing: conv.lastMessageAt != null
                            ? Text(
                                timeago.format(conv.lastMessageAt!,
                                    locale: isAr ? 'ar' : 'en'),
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight),
                              )
                            : null,
                        onTap: () => Navigation.to(ChatRoomScreen(
                          conversationId: conv.id,
                          otherName: name,
                          otherUserId: otherId,
                        )),
                      );
                    },
                  ),
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}
