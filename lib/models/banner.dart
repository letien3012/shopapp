import 'package:cloud_firestore/cloud_firestore.dart';

class Banner {
  final String id;
  final String imageUrl;
  final bool isHidden;
  final Timestamp createdAt;
  Timestamp? updatedAt;

  Banner({
    required this.id,
    required this.imageUrl,
    this.isHidden = false,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'isHidden': isHidden,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Banner copyWith({
    String? id,
    String? imageUrl,
    bool? isHidden,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Banner(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
