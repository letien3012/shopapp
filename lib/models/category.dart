import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final List<Category>? children;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final bool isHidden;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.children,
    Timestamp? createdAt,
    this.updatedAt,
    this.isHidden = false,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => Category.fromJson(child))
              .toList()
          : null,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp?,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'children': children?.map((child) => child.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isHidden': isHidden,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<Category>? children,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isHidden,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
