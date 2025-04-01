import 'dart:convert';

class ProductOption {
  String id;
  String name;
  String? imageUrl;
  int optionIndex;

  ProductOption({
    required this.id,
    required this.name,
    this.imageUrl,
    this.optionIndex = 0,
  });

  ProductOption copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? optionIndex,
  }) {
    return ProductOption(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      optionIndex: optionIndex ?? this.optionIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'optionIndex': optionIndex,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      id: map['id'] as String? ?? '',
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      optionIndex: map['optionIndex'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(id: $id, name: $name, imageUrl: $imageUrl, optionIndex: $optionIndex)';
  }
}
