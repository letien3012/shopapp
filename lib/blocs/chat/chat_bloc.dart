import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/models/message.dart';
import 'package:luanvan/services/chat_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;

  ChatBloc(this.chatService) : super(ChatInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<StartChatEvent>(_onStartChat);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
  }

  Future<void> _onLoadChatRooms(
      LoadChatRoomsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chatRooms = await chatService.getChatRoomsForUser(event.userId);
      emit(ChatRoomsLoaded(chatRooms));
    } catch (e) {
      emit(ChatError('Failed to load chat rooms: $e'));
    }
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await chatService.getMessages(event.chatRoomId);
      emit(MessagesLoaded(event.chatRoomId, messages));
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final message = Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: event.chatRoomId,
        senderId: event.senderId,
        content: event.content,
        imageUrl: event.imageUrl,
        productId: event.productId,
        orderId: event.orderId,
        sentAt: DateTime.now(),
      );
      await chatService.sendMessage(message);

      final messages = await chatService.getMessages(event.chatRoomId);
      emit(MessagesLoaded(event.chatRoomId, messages));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Future<void> _onStartChat(
      StartChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chatRoom = await chatService.startChat(event.buyerId, event.shopId);
      final messages = await chatService.getMessages(chatRoom.chatRoomId);
      // emit(MessagesLoaded(
      //     chatRoom.chatRoomId, messages.isEmpty ? [] : messages));
      emit(MessagesLoaded(chatRoom.chatRoomId, messages));
    } catch (e) {
      emit(ChatError('Failed to start chat: $e'));
    }
  }

  Future<void> _onMarkMessageAsRead(
      MarkMessageAsReadEvent event, Emitter<ChatState> emit) async {
    try {
      await chatService.markMessageAsRead(event.messageId);
      // Có thể tải lại tin nhắn nếu cần
    } catch (e) {
      emit(ChatError('Failed to mark message as read: $e'));
    }
  }
}
