import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatRoomId;
  final String buyerId;
  final String shopId;
  final DateTime createdAt;
  final String? lastMessageId;
  final bool isActive;
  final int unreadCountBuyer;
  final int unreadCountShop;

  ChatRoom({
    required this.chatRoomId,
    required this.buyerId,
    required this.shopId,
    required this.createdAt,
    this.lastMessageId,
    required this.isActive,
    this.unreadCountBuyer = 0,
    this.unreadCountShop = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'] as String,
      buyerId: json['buyerId'] as String,
      shopId: json['shopId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageId: json['lastMessageId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      unreadCountBuyer: json['unreadCountBuyer'] as int? ?? 0,
      unreadCountShop: json['unreadCountShop'] as int? ?? 0,
    );
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatRoomId: map['chatRoomId'] as String,
      buyerId: map['buyerId'] as String,
      shopId: map['shopId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastMessageId: map['lastMessageId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      unreadCountBuyer: map['unreadCountBuyer'] as int? ?? 0,
      unreadCountShop: map['unreadCountShop'] as int? ?? 0,
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
      isActive: firestoreData['isActive'] as bool? ?? true,
      unreadCountBuyer: firestoreData['unreadCountBuyer'] as int? ?? 0,
      unreadCountShop: firestoreData['unreadCountShop'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'buyerId': buyerId,
      'shopId': shopId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageId': lastMessageId,
      'isActive': isActive,
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountShop': unreadCountShop,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
