import 'package:cloud_firestore/cloud_firestore.dart'; // Import để dùng Timestamp

class Message {
  final String messageId;
  final String chatRoomId;
  final String senderId;
  final String content;
  final String? imageUrl;
  final String? productId;
  final String? orderId;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    this.productId,
    this.orderId,
    required this.sentAt,
    this.isRead = false,
  });

  // Chuyển từ JSON (tương tự fromJson cũ)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      productId: json['productId'] as String?,
      orderId: json['orderId'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  // Chuyển từ Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] as String,
      chatRoomId: map['chatRoomId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      imageUrl: map['imageUrl'] as String?,
      productId: map['productId'] as String?,
      orderId: map['orderId'] as String?,
      sentAt: DateTime.parse(map['sentAt'] as String),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  // Chuyển từ Firestore DocumentSnapshot
  factory Message.fromFirestore(Map<String, dynamic> firestoreData) {
    return Message(
      messageId: firestoreData['messageId'] as String,
      chatRoomId: firestoreData['chatRoomId'] as String,
      senderId: firestoreData['senderId'] as String,
      content: firestoreData['content'] as String,
      imageUrl: firestoreData['imageUrl'] as String?,
      productId: firestoreData['productId'] as String?,
      orderId: firestoreData['orderId'] as String?,
      // Xử lý sentAt: có thể là String hoặc Timestamp từ Firestore
      sentAt: firestoreData['sentAt'] is String
          ? DateTime.parse(firestoreData['sentAt'] as String)
          : (firestoreData['sentAt'] as Timestamp).toDate(),
      isRead: firestoreData['isRead'] as bool? ?? false,
    );
  }

  // Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'imageUrl': imageUrl,
      'productId': productId,
      'orderId': orderId,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
