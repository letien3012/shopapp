import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/blocs/chat_room/chat_room_bloc.dart';
import 'package:luanvan/blocs/chat_room/chat_room_event.dart';
import 'package:luanvan/models/message.dart';
import 'package:luanvan/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatBloc(this.chatService) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<StartChatEvent>(_onStartChat);
    on<ReadMessageEvent>(_onReadMessage);
    // on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
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

  Future<void> _onReadMessage(
      ReadMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final ChatRoomBloc chatRoomBloc;
      await chatService.updateRead(event.isShop, event.chatRoomId);
      if (event.isShop) {
        final shopId = event.chatRoomId.split('-')[1];
        // chatRoomBloc is declared but never initialized, so we need to initialize it
        final chatRoomBloc = ChatRoomBloc(chatService);
        chatRoomBloc.add(LoadChatRoomsShopEvent(shopId));
      } else {
        final userId = event.chatRoomId.split('-')[0];
        // chatRoomBloc is declared but never initialized, so we need to initialize it
        final chatRoomBloc = ChatRoomBloc(chatService);
        chatRoomBloc.add(LoadChatRoomsUserEvent(userId));
      }
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

  // Future<void> _onMarkMessageAsRead(
  //     MarkMessageAsReadEvent event, Emitter<ChatState> emit) async {
  //   try {
  //     await chatService.markMessageAsRead(event.messageId);
  //     // Có thể tải lại tin nhắn nếu cần
  //   } catch (e) {
  //     emit(ChatError('Failed to mark message as read: $e'));
  //   }
  // }

  Future<void> deleteEmptyChatRoom(String chatRoomId) async {
    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      final messages = await chatService.getMessages(chatRoomId);

      if (messages.isEmpty) {
        await chatRoomRef.delete();
      }
    } catch (e) {
      print('Lỗi khi xóa chatroom: $e');
    }
  }
}
