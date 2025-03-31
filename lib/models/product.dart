import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/option_info.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:intl/intl.dart';

class Product {
  String id;
  String name;
  int? quantity;
  int quantitySold;
  String description;
  double averageRating;
  List<ProductVariant> variants;
  List<String> imageUrl;
  String category;
  String videoUrl;
  String shopId;
  bool isViolated;
  String violationReason;
  bool isHidden;
  bool hasVariantImages;
  bool hasWeightVariant;
  double? weight;
  double? price;
  List<ShippingMethod> shippingMethods;
  List<OptionInfo> optionInfos; // Mảng 1 chiều lưu giá, kho, trọng lượng
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.quantity,
    required this.quantitySold,
    required this.description,
    required this.averageRating,
    required this.variants,
    this.imageUrl = const [],
    this.category = '',
    this.videoUrl = '',
    required this.shopId,
    this.isViolated = false,
    this.violationReason = '',
    this.isHidden = false,
    this.hasVariantImages = false,
    this.hasWeightVariant = false,
    this.weight,
    this.price,
    required this.shippingMethods,
    this.optionInfos = const [], // Khởi tạo mảng rỗng
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Product copyWith({
    String? id,
    String? name,
    int? quantity,
    int? quantitySold,
    String? description,
    double? averageRating,
    List<ProductVariant>? variants,
    List<String>? imageUrl,
    String? category,
    String? videoUrl,
    String? shopId,
    bool? isViolated,
    String? violationReason,
    bool? isHidden,
    bool? hasVariantImages,
    bool? hasWeightVariant,
    double? weight,
    double? price,
    List<ShippingMethod>? shippingMethods,
    List<OptionInfo>? optionInfos,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      quantitySold: quantitySold ?? this.quantitySold,
      description: description ?? this.description,
      averageRating: averageRating ?? this.averageRating,
      variants: variants ?? this.variants,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      shopId: shopId ?? this.shopId,
      isViolated: isViolated ?? this.isViolated,
      violationReason: violationReason ?? this.violationReason,
      isHidden: isHidden ?? this.isHidden,
      hasVariantImages: hasVariantImages ?? this.hasVariantImages,
      hasWeightVariant: hasWeightVariant ?? this.hasWeightVariant,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      shippingMethods: shippingMethods ?? this.shippingMethods,
      optionInfos: optionInfos ?? this.optionInfos,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'quantitySold': quantitySold,
      'description': description,
      'averageRating': averageRating,
      'variants': variants.map((x) => x.toMap()).toList(),
      'imageUrl': imageUrl,
      'category': category,
      'videoUrl': videoUrl,
      'shopId': shopId,
      'isViolated': isViolated,
      'violationReason': violationReason,
      'isHidden': isHidden,
      'hasVariantImages': hasVariantImages,
      'hasWeightVariant': hasWeightVariant,
      'weight': weight,
      'price': price,
      'shippingMethods': shippingMethods.map((x) => x.toMap()).toList(),
      'optionInfos': optionInfos.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int?,
      quantitySold: map['quantitySold'] as int,
      description: map['description'] as String,
      averageRating: map['averageRating'] as double,
      variants: List<ProductVariant>.from(
        (map['variants'] as List<dynamic>).map<ProductVariant>(
          (x) => ProductVariant.fromMap(x as Map<String, dynamic>),
        ),
      ),
      imageUrl: List<String>.from(map['imageUrl'] as List<dynamic>? ?? []),
      category: map['category'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      shopId: map['shopId'] as String,
      isViolated: map['isViolated'] as bool? ?? false,
      violationReason: map['violationReason'] as String? ?? '',
      isHidden: map['isHidden'] as bool? ?? false,
      hasVariantImages: map['hasVariantImages'] as bool? ?? false,
      hasWeightVariant: map['hasWeightVariant'] as bool? ?? false,
      weight: map['weight'] as double?,
      price: map['price'] as double?,
      shippingMethods: List<ShippingMethod>.from(
        (map['shippingMethods'] as List<dynamic>? ?? []).map<ShippingMethod>(
          (x) => ShippingMethod.fromMap(x as Map<String, dynamic>),
        ),
      ),
      optionInfos: List<OptionInfo>.from(
        (map['optionInfos'] as List<dynamic>? ?? []).map<OptionInfo>(
          (x) => OptionInfo.fromMap(x as Map<String, dynamic>),
        ),
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as int?,
      quantitySold: data['quantitySold'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      variants: data['variants'] != null
          ? List<ProductVariant>.from(
              (data['variants'] as List<dynamic>).map<ProductVariant>(
                (x) => ProductVariant.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      imageUrl: data['imageUrl'] != null
          ? List<String>.from(data['imageUrl'] as List<dynamic>)
          : [],
      category: data['category'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      isViolated: data['isViolated'] as bool? ?? false,
      violationReason: data['violationReason'] as String? ?? '',
      isHidden: data['isHidden'] as bool? ?? false,
      hasVariantImages: data['hasVariantImages'] as bool? ?? false,
      hasWeightVariant: data['hasWeightVariant'] as bool? ?? false,
      weight: data['weight'] as double?,
      price: data['price'] as double?,
      shippingMethods: data['shippingMethods'] != null
          ? List<ShippingMethod>.from(
              (data['shippingMethods'] as List<dynamic>).map<ShippingMethod>(
                (x) => ShippingMethod.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      optionInfos: data['optionInfos'] != null
          ? List<OptionInfo>.from(
              (data['optionInfos'] as List<dynamic>).map<OptionInfo>(
                (x) => OptionInfo.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, quantity: $quantity, quantitySold: $quantitySold, description: $description, averageRating: $averageRating, variants: $variants, imageUrl: $imageUrl, category: $category, videoUrl: $videoUrl, shopId: $shopId, isViolated: $isViolated, violationReason: $violationReason, isHidden: $isHidden, hasVariantImages: $hasVariantImages, hasWeightVariant: $hasWeightVariant, weight: $weight, price: $price, shippingMethods: $shippingMethods, optionInfos: $optionInfos)';
  }

  double getMaxOptionPrice() {
    if (variants.isEmpty || optionInfos.isEmpty) return price ?? 0.0;
    List<double> allPrices = optionInfos.map((info) => info.price).toList();
    return allPrices.reduce((a, b) => a > b ? a : b);
  }

  double getMinOptionPrice() {
    if (variants.isEmpty || optionInfos.isEmpty) return price ?? 0.0;
    List<double> allPrices = optionInfos.map((info) => info.price).toList();
    return allPrices.reduce((a, b) => a < b ? a : b);
  }

  int getMaxOptionStock() {
    if (variants.isEmpty || optionInfos.isEmpty) return quantity ?? 0;
    List<int> allStocks = optionInfos.map((info) => info.stock).toList();
    return allStocks.reduce((a, b) => a > b ? a : b);
  }

  int getMinOptionStock() {
    if (variants.isEmpty || optionInfos.isEmpty) return quantity ?? 0;
    List<int> allStocks = optionInfos.map((info) => info.stock).toList();
    return allStocks.reduce((a, b) => a < b ? a : b);
  }

  int getTotalOptionStock() {
    if (variants.isEmpty || optionInfos.isEmpty) return quantity ?? 0;
    List<int> allStocks = optionInfos.map((info) => info.stock).toList();
    return allStocks.reduce((a, b) => a + b);
  }

  int getTotalOptionsCount() {
    if (variants.isEmpty) return 0;
    return variants.fold(0, (total, variant) => total + variant.options.length);
  }

  String getFormattedPriceText() {
    if (variants.isEmpty) {
      return formatPrice(price!);
    }

    double minPrice = getMinOptionPrice();
    double maxPrice = getMaxOptionPrice();

    if (minPrice == maxPrice) {
      return formatPrice(minPrice);
    }
    return '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price.toInt());
  }
}
