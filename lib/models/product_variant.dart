import 'dart:convert';
import 'package:luanvan/models/product_option.dart';

class ProductVariant {
  String id;
  String label;
  List<ProductOption> options;
  int variantIndex;

  ProductVariant({
    required this.id,
    required this.label,
    required this.options,
    this.variantIndex = 0,
  });

  ProductVariant copyWith({
    String? id,
    String? label,
    List<ProductOption>? options,
    int? variantIndex,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      label: label ?? this.label,
      options: options ?? this.options,
      variantIndex: variantIndex ?? this.variantIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'options': options.map((option) => option.toMap()).toList(),
      'variantIndex': variantIndex,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'variantIndex': variantIndex,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((option) =>
                  ProductOption.fromMap(option as Map<String, dynamic>))
              .toList() ??
          [],
      variantIndex: map['variantIndex'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductVariant.fromJson(String source) =>
      ProductVariant.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ProductVariant(id: $id, label: $label, options: $options, variantIndex: $variantIndex)';
}
