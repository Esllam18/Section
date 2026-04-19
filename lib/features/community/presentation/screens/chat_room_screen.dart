// lib/features/community/presentation/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/community/data/repositories/chat_repository.dart';
import 'package:section/features/community/presentation/cubit/chat_cubit.dart';
import 'package:section/features/community/presentation/cubit/chat_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomScreen extends StatelessWidget {
  final String conversationId;
  final String otherName;
  final String otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherName,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            ChatRoomCubit(ChatRepository())..loadMessages(conversationId),
        child: _ChatRoomBody(
          conversationId: conversationId,
          otherName: otherName,
        ),
      );
}

class _ChatRoomBody extends StatefulWidget {
  final String conversationId;
  final String otherName;
  const _ChatRoomBody(
      {required this.conversationId, required this.otherName});

  @override
  State<_ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends State<_ChatRoomBody> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut);
      }
    });
  }

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
            title: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  widget.otherName.isNotEmpty
                      ? widget.otherName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.otherName,
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ]),
          ),
          body: BlocConsumer<ChatRoomCubit, ChatRoomState>(
            listener: (_, s) {
              if (s.status == ChatStatus.loaded) _scrollToBottom();
            },
            builder: (ctx, state) => Column(
              children: [
                Expanded(
                  child: state.status == ChatStatus.loading
                      ? const LoadingWidget()
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(12),
                          itemCount: state.messages.length,
                          itemBuilder: (_, i) {
                            final msg = state.messages[i];
                            final isMe = msg.senderId == myId;
                            return _Bubble(
                              body: msg.body,
                              isMe: isMe,
                              isAr: isAr,
                              time: timeago.format(msg.createdAt,
                                  locale: isAr ? 'ar' : 'en'),
                            );
                          },
                        ),
                ),
                _InputBar(
                  ctrl: _ctrl,
                  isAr: isAr,
                  sending: state.sending,
                  onSend: () {
                    if (_ctrl.text.trim().isEmpty) return;
                    ctx.read<ChatRoomCubit>().send(
                          convId: widget.conversationId,
                          body: _ctrl.text.trim(),
                        );
                    _ctrl.clear();
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final String body, time;
  final bool isMe, isAr;
  const _Bubble(
      {required this.body,
      required this.isMe,
      required this.isAr,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isAr, sending;
  final VoidCallback onSend;
  const _InputBar(
      {required this.ctrl,
      required this.isAr,
      required this.sending,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
              color:
                  isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: InputDecoration(
                hintText: isAr ? 'اكتب رسالة...' : 'Type a message...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: sending ? null : AppColors.primaryGradient,
                color: sending ? AppColors.dividerLight : null,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
