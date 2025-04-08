class ImportItem {
  String productId;
  String? optionId1;
  String? optionId2;
  int quantity;
  double price;

  ImportItem({
    required this.productId,
    this.optionId1,
    this.optionId2,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'optionId1': optionId1,
      'optionId2': optionId2,
      'quantity': quantity,
      'price': price,
    };
  }

  factory ImportItem.fromMap(Map<String, dynamic> map) {
    return ImportItem(
      productId: map['productId'],
      optionId1: map['optionId1'],
      optionId2: map['optionId2'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
    );
  }
}
