class OptionInfo {
  double price;
  int stock;
  double? weight;

  OptionInfo({
    required this.price,
    required this.stock,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'stock': stock,
      'weight': weight,
    };
  }

  factory OptionInfo.fromMap(Map<String, dynamic> map) {
    return OptionInfo(
      price: map['price'] as double,
      stock: map['stock'] as int,
      weight: map['weight'] as double?,
    );
  }

  OptionInfo copyWith({
    double? price,
    int? stock,
    double? weight,
  }) {
    return OptionInfo(
      price: price ?? this.price,
      stock: stock ?? this.stock,
      weight: weight ?? this.weight,
    );
  }

  @override
  String toString() {
    return 'OptionInfo(price: $price, stock: $stock, weight: $weight)';
  }
}
