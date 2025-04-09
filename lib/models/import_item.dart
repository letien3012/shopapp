class ImportItem {
  String productId;
  String productName;
  String imageUrl;
  String? optionName;
  String? optionId1;
  String? optionId2;
  int quantity;
  double price;
  int? adjustmentQuantities;

  ImportItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    this.optionName,
    this.optionId1,
    this.optionId2,
    required this.quantity,
    required this.price,
    this.adjustmentQuantities,
  });

  ImportItem copyWith({
    String? productId,
    String? productName,
    String? imageUrl,
    String? optionName,
    String? optionId1,
    String? optionId2,
    int? quantity,
    double? price,
    int? adjustmentQuantities,
  }) {
    return ImportItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      optionName: optionName ?? this.optionName,
      optionId1: optionId1 ?? this.optionId1,
      optionId2: optionId2 ?? this.optionId2,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      adjustmentQuantities: adjustmentQuantities ?? this.adjustmentQuantities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'optionName': optionName,
      'optionId1': optionId1,
      'optionId2': optionId2,
      'quantity': quantity,
      'price': price,
      'adjustmentQuantities': adjustmentQuantities,
    };
  }

  factory ImportItem.fromMap(Map<String, dynamic> map) {
    return ImportItem(
      productId: map['productId'],
      productName: map['productName'],
      imageUrl: map['imageUrl'],
      optionName: map['optionName'],
      optionId1: map['optionId1'],
      optionId2: map['optionId2'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      adjustmentQuantities: map['adjustmentQuantities'],
    );
  }
}
