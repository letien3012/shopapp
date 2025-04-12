class ProductChatbot {
  final String productId;
  final String name;
  final String price;
  final String imageUrl;

  ProductChatbot({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory ProductChatbot.fromJson(Map<String, dynamic> json) {
    return ProductChatbot(
      productId: json['productId'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }
}
