import 'package:luanvan/models/chat_room.dart';
import 'package:luanvan/models/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;
  ChatRoomsLoaded(this.chatRooms);
}

class MessagesLoaded extends ChatState {
  final String chatRoomId;
  final List<Message> messages;
  MessagesLoaded(this.chatRoomId, this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
