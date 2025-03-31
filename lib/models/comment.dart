import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String productId;
  final String content;
  final int rating;
  final List<String> images;
  final DateTime createdAt;
  final String? replyContent;
  final DateTime? replyAt;
  final String? shopId;
  final bool isVerified;
  final CommentVariant? variant;
  final String orderId;
  final String? videoUrl;

  Comment({
    required this.id,
    required this.userId,
    required this.productId,
    required this.content,
    required this.rating,
    required this.images,
    required this.createdAt,
    this.replyContent,
    this.replyAt,
    this.shopId,
    this.isVerified = false,
    this.variant,
    required this.orderId,
    this.videoUrl,
  });

  // Tạo Comment từ Map (JSON)
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      content: map['content'] as String,
      rating: map['rating'] as int,
      images: List<String>.from(map['images'] as List),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      replyContent: map['replyContent'] as String?,
      replyAt: map['replyAt'] != null
          ? (map['replyAt'] as Timestamp).toDate()
          : null,
      shopId: map['shopId'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      variant: map['variant'] != null
          ? CommentVariant.fromMap(map['variant'] as Map<String, dynamic>)
          : null,
      orderId: map['orderId'] as String,
      videoUrl: map['videoUrl'] as String?,
    );
  }

  // Chuyển Comment thành Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'content': content,
      'rating': rating,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'replyContent': replyContent,
      'replyAt': replyAt != null ? Timestamp.fromDate(replyAt!) : null,
      'shopId': shopId,
      'isVerified': isVerified,
      'variant': variant?.toMap(),
      'orderId': orderId,
      'videoUrl': videoUrl,
    };
  }

  // Copy với các thuộc tính mới
  Comment copyWith({
    String? id,
    String? userId,
    String? productId,
    String? content,
    int? rating,
    List<String>? images,
    DateTime? createdAt,
    String? replyContent,
    DateTime? replyAt,
    String? shopId,
    bool? isVerified,
    CommentVariant? variant,
    String? orderId,
    String? videoUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      replyContent: replyContent ?? this.replyContent,
      replyAt: replyAt ?? this.replyAt,
      shopId: shopId ?? this.shopId,
      isVerified: isVerified ?? this.isVerified,
      variant: variant ?? this.variant,
      orderId: orderId ?? this.orderId,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  // So sánh hai Comment
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment &&
        other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.rating == rating &&
        other.createdAt == createdAt &&
        other.replyContent == replyContent &&
        other.replyAt == replyAt &&
        other.shopId == shopId &&
        other.isVerified == isVerified &&
        other.variant == variant &&
        other.orderId == orderId &&
        other.videoUrl == videoUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        rating.hashCode ^
        createdAt.hashCode ^
        replyContent.hashCode ^
        replyAt.hashCode ^
        shopId.hashCode ^
        isVerified.hashCode ^
        variant.hashCode ^
        orderId.hashCode ^
        videoUrl.hashCode;
  }

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId,  rating: $rating, content: $content)';
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      rating: data['rating'] as int,
      images: data['images'] != null
          ? List<String>.from(data['images'] as List<dynamic>)
          : [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      replyContent: data['replyContent'] as String?,
      replyAt: data['replyAt'] != null
          ? (data['replyAt'] as Timestamp).toDate()
          : null,
      shopId: data['shopId'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      variant: data['variant'] != null
          ? CommentVariant.fromMap(data['variant'] as Map<String, dynamic>)
          : null,
      orderId: data['orderId'] as String? ?? '',
      videoUrl: data['videoUrl'] as String?,
    );
  }
}

// Model để lưu thông tin variant của sản phẩm trong comment
class CommentVariant {
  final String? variantId1;
  final String? optionId1;
  final String? variantId2;
  final String? optionId2;
  final String? variantLabel1;
  final String? variantLabel2;
  final String? optionName1;
  final String? optionName2;

  CommentVariant({
    this.variantId1,
    this.optionId1,
    this.variantId2,
    this.optionId2,
    this.variantLabel1,
    this.variantLabel2,
    this.optionName1,
    this.optionName2,
  });

  Map<String, dynamic> toMap() {
    return {
      'variantId1': variantId1,
      'optionId1': optionId1,
      'variantId2': variantId2,
      'optionId2': optionId2,
      'variantLabel1': variantLabel1,
      'variantLabel2': variantLabel2,
      'optionName1': optionName1,
      'optionName2': optionName2,
    };
  }

  factory CommentVariant.fromMap(Map<String, dynamic> map) {
    return CommentVariant(
      variantId1: map['variantId1'] as String?,
      optionId1: map['optionId1'] as String?,
      variantId2: map['variantId2'] as String?,
      optionId2: map['optionId2'] as String?,
      variantLabel1: map['variantLabel1'] as String?,
      variantLabel2: map['variantLabel2'] as String?,
      optionName1: map['optionName1'] as String?,
      optionName2: map['optionName2'] as String?,
    );
  }

  String getDisplayText() {
    if (variantId1 == null) return '';
    if (variantId2 == null) {
      return '$variantLabel1: $optionName1';
    }
    return '$variantLabel1: $optionName1, $variantLabel2: $optionName2';
  }
}
