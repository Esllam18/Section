import 'package:equatable/equatable.dart';
import 'package:section/features/ai_assistant/data/models/ai_message_model.dart';
enum AiChatStatus { idle, loading, error }
class AiChatState extends Equatable {
  final AiChatStatus status;
  final List<AiMessageModel> messages;
  final String? errorMessage;
  final bool showQuickChips;
  const AiChatState({this.status = AiChatStatus.idle, this.messages = const [], this.errorMessage, this.showQuickChips = true});
  AiChatState copyWith({AiChatStatus? status, List<AiMessageModel>? messages, String? errorMessage, bool? showQuickChips}) =>
    AiChatState(status: status ?? this.status, messages: messages ?? this.messages, errorMessage: errorMessage, showQuickChips: showQuickChips ?? this.showQuickChips);
  @override List<Object?> get props => [status, messages, errorMessage, showQuickChips];
}
