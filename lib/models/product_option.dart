import 'dart:convert';

class ProductOption {
  String name;
  String? imageUrl;

  ProductOption({
    required this.name,
    this.imageUrl,
  });

  ProductOption copyWith({
    String? name,
    String? imageUrl,
  }) {
    return ProductOption(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(name: $name, imageUrl: $imageUrl)';
  }
}
