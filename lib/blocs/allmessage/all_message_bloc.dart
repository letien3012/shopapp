import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/allmessage/all_message_event.dart';
import 'package:luanvan/blocs/allmessage/all_message_state.dart';
import 'package:luanvan/services/chat_service.dart';

class AllMessageBloc extends Bloc<AllMessageEvent, AllMessageState> {
  final ChatService chatService;

  AllMessageBloc(this.chatService) : super(AllMessageInitial()) {
    on<LoadAllMessagesEvent>(_onLoadAllMessages);
  }

  Future<void> _onLoadAllMessages(
      LoadAllMessagesEvent event, Emitter<AllMessageState> emit) async {
    emit(AllMessageLoading());
    try {
      final messages = await chatService.getAllMessages();
      emit(AllMessageLoaded(messages));
    } catch (e) {
      emit(AllMessageError('Failed to load messages: $e'));
    }
  }
}
