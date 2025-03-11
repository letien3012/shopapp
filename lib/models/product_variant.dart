import 'dart:convert';
import 'package:luanvan/models/product_option.dart';

class ProductVariant {
  String label;
  List<ProductOption> options;

  ProductVariant({
    required this.label,
    required this.options,
  });

  ProductVariant copyWith({
    String? label,
    List<ProductOption>? options,
  }) {
    return ProductVariant(
      label: label ?? this.label,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      label: map['label'] as String? ?? '',
      options: map['options'] != null
          ? List<ProductOption>.from(
              (map['options'] as List<dynamic>).map<ProductOption>(
                (x) => ProductOption.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductVariant.fromJson(String source) =>
      ProductVariant.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProductVariant(label: $label, options: $options)';
}
