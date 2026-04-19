import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:section/features/ai_assistant/data/models/ai_message_model.dart';
import 'package:section/features/ai_assistant/data/repositories/ai_repository.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiRepository _repo;
  final String _faculty;
  final int _year;
  final _uuid = const Uuid();

  AiChatCubit(this._repo, {required String faculty, required int academicYear})
    : _faculty = faculty, _year = academicYear, super(const AiChatState());

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final userMsg = AiMessageModel(id: _uuid.v4(), role: 'user', content: content.trim(), createdAt: DateTime.now());
    emit(state.copyWith(messages: [...state.messages, userMsg], status: AiChatStatus.loading, showQuickChips: false, errorMessage: null));
    try {
      final history = [...state.messages.map((m) => m.toGroqMessage()), userMsg.toGroqMessage()];
      final reply = await _repo.sendMessage(messages: history, faculty: _faculty, academicYear: _year);
      final aiMsg = AiMessageModel(id: _uuid.v4(), role: 'assistant', content: reply, createdAt: DateTime.now());
      emit(state.copyWith(messages: [...state.messages, aiMsg], status: AiChatStatus.idle));
    } catch (e) {
      emit(state.copyWith(status: AiChatStatus.error, errorMessage: e.toString()));
    }
  }

  void clearChat() => emit(const AiChatState());
}
