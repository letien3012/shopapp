import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/blocs/chat_room/chat_room_event.dart';
import 'package:luanvan/blocs/chat_room/chat_room_state.dart';
import 'package:luanvan/models/message.dart';
import 'package:luanvan/services/chat_service.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatService chatService;

  ChatRoomBloc(this.chatService) : super(ChatRoomInitial()) {
    on<LoadChatRoomEventByChatRoomId>(_onLoadChatRoomByChatRoomId);
    on<LoadChatRoomsUserEvent>(_onLoadChatUserRooms);
    on<LoadChatRoomsShopEvent>(_onLoadChatRoomsShop);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
  }
  Future<void> _onLoadChatRoomByChatRoomId(
      LoadChatRoomEventByChatRoomId event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoading());
    try {
      final chatRooms = await chatService.getChatRoomsById(event.chatRoomId);
      emit(ChatRoomLoaded(chatRooms));
    } catch (e) {
      emit(ChatRoomError('Failed to load chat rooms: $e'));
    }
  }

  Future<void> _onLoadChatUserRooms(
      LoadChatRoomsUserEvent event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoading());
    try {
      final chatRooms = await chatService.getChatRoomsForUser(event.userId);
      emit(ChatRoomsUserLoaded(chatRooms));
    } catch (e) {
      emit(ChatRoomError('Failed to load chat rooms: $e'));
    }
  }

  Future<void> _onLoadChatRoomsShop(
      LoadChatRoomsShopEvent event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoading());
    try {
      final chatRooms = await chatService.getChatRoomsForShop(event.shopId);
      emit(ChatRoomsShopLoaded(chatRooms));
    } catch (e) {
      emit(ChatRoomError('Failed to load chat rooms: $e'));
    }
  }

  Future<void> _onMarkMessageAsRead(
      MarkMessageAsReadEvent event, Emitter<ChatRoomState> emit) async {
    try {
      await chatService.markMessageAsRead(event.messageId);
      // Có thể tải lại tin nhắn nếu cần
    } catch (e) {
      emit(ChatRoomError('Failed to mark message as read: $e'));
    }
  }
}
