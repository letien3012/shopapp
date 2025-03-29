abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatRoomId;
  LoadMessagesEvent(this.chatRoomId);
}

class SendMessageEvent extends ChatEvent {
  final String chatRoomId;
  final String senderId;
  final String content;
  final String? imageUrl;
  final String? productId;
  final String? orderId;
  SendMessageEvent({
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    this.productId,
    this.orderId,
  });
}

class StartChatEvent extends ChatEvent {
  final String buyerId;
  final String shopId;
  StartChatEvent(this.buyerId, this.shopId);
}

// class MarkMessageAsReadEvent extends ChatEvent {
//   final String messageId;
//   MarkMessageAsReadEvent(this.messageId);
// }
