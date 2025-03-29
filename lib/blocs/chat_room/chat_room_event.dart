abstract class ChatRoomEvent {}

class LoadChatRoomEventByChatRoomId extends ChatRoomEvent {
  final String chatRoomId;
  LoadChatRoomEventByChatRoomId(this.chatRoomId);
}

class LoadChatRoomsUserEvent extends ChatRoomEvent {
  final String userId;
  LoadChatRoomsUserEvent(this.userId);
}

class LoadChatRoomsShopEvent extends ChatRoomEvent {
  final String shopId;
  LoadChatRoomsShopEvent(this.shopId);
}

class MarkMessageAsReadEvent extends ChatRoomEvent {
  final String messageId;
  MarkMessageAsReadEvent(this.messageId);
}
