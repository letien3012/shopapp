class ImageFeature {
  final String imageUrl;
  final String productId;
  final List<double> features;

  ImageFeature({
    required this.imageUrl,
    required this.productId,
    required this.features,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'productId': productId,
      'features': features,
    };
  }

  factory ImageFeature.fromJson(Map<String, dynamic> json) {
    return ImageFeature(
      imageUrl: json['imageUrl'],
      productId: json['productId'],
      features: List<double>.from(json['features']),
    );
  }
}
