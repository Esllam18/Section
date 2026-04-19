import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/community/data/models/chat_message_model.dart';
import 'package:section/features/community/data/repositories/chat_repository.dart';
import 'chat_state.dart';
class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository _r; ChatListCubit(this._r) : super(const ChatListState());
  Future<void> load() async {
    emit(state.copyWith(status:ChatStatus.loading));
    try { emit(state.copyWith(status:ChatStatus.loaded,conversations:await _r.getConversations())); }
    catch(e) { emit(state.copyWith(status:ChatStatus.error,error:e.toString())); }
  }
}
class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepository _r; ChatRoomCubit(this._r) : super(const ChatRoomState());
  Future<void> loadMessages(String id) async {
    emit(state.copyWith(status:ChatStatus.loading));
    try {
      final msgs = await _r.getMessages(id);
      emit(state.copyWith(status:ChatStatus.loaded,messages:msgs));
      _r.subscribe(id, (m) { if(!isClosed) emit(state.copyWith(messages:[...state.messages,m])); });
    } catch(e) { emit(state.copyWith(status:ChatStatus.error)); }
  }
  Future<void> send({required String convId, required String body}) async {
    if(body.trim().isEmpty) return;
    emit(state.copyWith(sending:true));
    try {
      final m = await _r.sendMessage(convId:convId,body:body.trim());
      emit(state.copyWith(sending:false,messages:[...state.messages,m]));
    } catch(_) { emit(state.copyWith(sending:false)); }
  }
  @override Future<void> close() { _r.unsubscribe(); return super.close(); }
}
