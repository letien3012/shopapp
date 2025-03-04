// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:luanvan/models/product_option.dart';

class ProductVariant {
  final String id;
  final String label;
  List<ProductOption> options;
  ProductVariant({
    required this.id,
    required this.label,
    required this.options,
  });

  ProductVariant copyWith({
    String? id,
    String? label,
    List<ProductOption>? options,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      label: label ?? this.label,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String,
      label: map['label'] as String,
      options: List<ProductOption>.from(
        (map['options'] as List<int>).map<ProductOption>(
          (x) => ProductOption.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductVariant.fromJson(String source) =>
      ProductVariant.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ProductVariant(id: $id, label: $label, options: $options)';

  @override
  bool operator ==(covariant ProductVariant other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        listEquals(other.options, options);
  }

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ options.hashCode;
}
