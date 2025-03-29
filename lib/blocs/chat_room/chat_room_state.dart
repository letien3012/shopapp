import 'package:luanvan/models/chat_room.dart';

abstract class ChatRoomState {}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final ChatRoom chatRoom;
  ChatRoomLoaded(this.chatRoom);
}

class ChatRoomsUserLoaded extends ChatRoomState {
  final List<ChatRoom> chatRooms;
  ChatRoomsUserLoaded(this.chatRooms);
}

class ChatRoomsShopLoaded extends ChatRoomState {
  final List<ChatRoom> chatRooms;
  ChatRoomsShopLoaded(this.chatRooms);
}

class ChatRoomError extends ChatRoomState {
  final String message;
  ChatRoomError(this.message);
}
