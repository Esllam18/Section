import 'package:equatable/equatable.dart';
import 'package:section/features/community/data/models/chat_conversation_model.dart';
import 'package:section/features/community/data/models/chat_message_model.dart';
enum ChatStatus { initial, loading, loaded, error }
class ChatListState extends Equatable {
  final ChatStatus status; final List<ChatConversationModel> conversations; final String? error;
  const ChatListState({this.status=ChatStatus.initial,this.conversations=const[],this.error});
  ChatListState copyWith({ChatStatus? status,List<ChatConversationModel>? conversations,String? error}) =>
    ChatListState(status:status??this.status,conversations:conversations??this.conversations,error:error);
  @override List<Object?> get props => [status,conversations,error];
}
class ChatRoomState extends Equatable {
  final ChatStatus status; final List<ChatMessageModel> messages; final bool sending;
  const ChatRoomState({this.status=ChatStatus.initial,this.messages=const[],this.sending=false});
  ChatRoomState copyWith({ChatStatus? status,List<ChatMessageModel>? messages,bool? sending}) =>
    ChatRoomState(status:status??this.status,messages:messages??this.messages,sending:sending??this.sending);
  @override List<Object?> get props => [status,messages,sending];
}
