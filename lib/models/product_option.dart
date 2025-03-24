import 'dart:convert';

class ProductOption {
  String id;
  String name;
  String? imageUrl;

  ProductOption({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  ProductOption copyWith({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return ProductOption(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      id: map['id'] as String? ?? '',
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(id: $id, name: $name, imageUrl: $imageUrl)';
  }
}
