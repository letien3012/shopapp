import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatRoomId;
  final String buyerId;
  final String shopId;
  final DateTime createdAt;
  final String? lastMessageId;
  final int unreadCountBuyer;
  final int unreadCountShop;
  final String lastMessageSenderId;

  ChatRoom({
    required this.chatRoomId,
    required this.buyerId,
    required this.shopId,
    required this.createdAt,
    this.lastMessageId,
    this.unreadCountBuyer = 0,
    this.unreadCountShop = 0,
    required this.lastMessageSenderId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'] as String,
      buyerId: json['buyerId'] as String,
      shopId: json['shopId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageId: json['lastMessageId'] as String?,
      unreadCountBuyer: json['unreadCountBuyer'] as int? ?? 0,
      unreadCountShop: json['unreadCountShop'] as int? ?? 0,
      lastMessageSenderId: json['lastMessageSenderId'] as String,
    );
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatRoomId: map['chatRoomId'] as String,
      buyerId: map['buyerId'] as String,
      shopId: map['shopId'] as String,
      unreadCountBuyer: map['unreadCountBuyer'] as int,
      unreadCountShop: map['unreadCountShop'] as int,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessageId: map['lastMessageId'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String,
    );
  }

  factory ChatRoom.fromFirestore(Map<String, dynamic> firestoreData) {
    return ChatRoom(
      chatRoomId: firestoreData['chatRoomId'] as String,
      buyerId: firestoreData['buyerId'] as String,
      shopId: firestoreData['shopId'] as String,
      createdAt: firestoreData['createdAt'] is String
          ? DateTime.parse(firestoreData['createdAt'] as String)
          : (firestoreData['createdAt'] as Timestamp).toDate(),
      lastMessageId: firestoreData['lastMessageId'] as String?,
      unreadCountBuyer: firestoreData['unreadCountBuyer'] as int? ?? 0,
      unreadCountShop: firestoreData['unreadCountShop'] as int? ?? 0,
      lastMessageSenderId: firestoreData['lastMessageSenderId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'buyerId': buyerId,
      'shopId': shopId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageId': lastMessageId,
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountShop': unreadCountShop,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
