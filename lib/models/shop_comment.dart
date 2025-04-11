import 'package:cloud_firestore/cloud_firestore.dart';

class ShopComment {
  final String id;
  final String userId;
  final String shopId;
  final int rating;
  final DateTime createdAt;
  final String? reply;
  final DateTime? replyAt;
  final String orderId;

  ShopComment({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.rating,
    required this.createdAt,
    this.reply,
    this.replyAt,
    required this.orderId,
  });

  factory ShopComment.fromMap(Map<String, dynamic> map) {
    return ShopComment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      shopId: map['shopId'] as String,
      rating: map['rating'] as int,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reply: map['reply'] as String?,
      replyAt: map['replyAt'] != null
          ? (map['replyAt'] as Timestamp).toDate()
          : null,
      orderId: map['orderId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'reply': reply,
      'replyAt': replyAt != null ? Timestamp.fromDate(replyAt!) : null,
      'orderId': orderId,
    };
  }

  ShopComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? shopId,
    int? rating,
    DateTime? createdAt,
    String? reply,
    DateTime? replyAt,
    String? orderId,
  }) {
    return ShopComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      reply: reply ?? this.reply,
      replyAt: replyAt ?? this.replyAt,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShopComment &&
        other.id == id &&
        other.userId == userId &&
        other.shopId == shopId &&
        other.rating == rating &&
        other.createdAt == createdAt &&
        other.reply == reply &&
        other.replyAt == replyAt &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        shopId.hashCode ^
        rating.hashCode ^
        createdAt.hashCode ^
        reply.hashCode ^
        replyAt.hashCode ^
        orderId.hashCode;
  }

  @override
  String toString() {
    return 'ShopComment(id: $id, userId: $userId,  rating: $rating)';
  }

  factory ShopComment.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopComment(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      rating: data['rating'] as int,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      reply: data['reply'] as String?,
      replyAt: data['replyAt'] != null
          ? (data['replyAt'] as Timestamp).toDate()
          : null,
      orderId: data['orderId'] as String? ?? '',
    );
  }
}
