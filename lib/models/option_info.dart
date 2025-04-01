class OptionInfo {
  String? optionId1;
  String? optionId2;
  double price;
  int stock;
  double? weight;

  OptionInfo({
    this.optionId1,
    this.optionId2,
    required this.price,
    required this.stock,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'optionId1': optionId1,
      'optionId2': optionId2,
      'price': price,
      'stock': stock,
      'weight': weight,
    };
  }

  factory OptionInfo.fromMap(Map<String, dynamic> map) {
    return OptionInfo(
      optionId1: map['optionId1'] as String?,
      optionId2: map['optionId2'] as String?,
      price: double.parse(map['price'].toString()),
      stock: int.parse(map['stock'].toString()),
      weight:
          map['weight'] != null ? double.parse(map['weight'].toString()) : null,
    );
  }

  OptionInfo copyWith({
    String? optionId1,
    String? optionId2,
    double? price,
    int? stock,
    double? weight,
  }) {
    return OptionInfo(
      optionId1: optionId1 ?? this.optionId1,
      optionId2: optionId2 ?? this.optionId2,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      weight: weight ?? this.weight,
    );
  }

  @override
  String toString() {
    return 'OptionInfo(optionId1: $optionId1, optionId2: $optionId2, price: $price, stock: $stock, weight: $weight)';
  }
}
