import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/user_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  // Future<List<String>> fetchRecommendedProducts(String productId) async {
  //   final url = Uri.parse(
  //       'http://192.168.33.8:5000/api/product-recommendations?id=$productId');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return List<String>.from(data['related_products']);
  //     } else {
  //       print('Lỗi status: ${response.statusCode}');
  //       print(response.body);
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Lỗi khi gọi API: $e');
  //     return [];
  //   }
  // }
  double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  Future<List<String>> fetchRecommendedProducts(String productId) async {
    final productEmbeddingSnapshot = await _firestore
        .collection('product_embedding')
        .where('productId', isEqualTo: productId)
        .get();
    final allProductEmbedding = await _firestore
        .collection('product_embedding')
        .where('isHidden', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .get();
    final productEmbedding =
        List<double>.from(productEmbeddingSnapshot.docs.first['embeddings']);
    final results = allProductEmbedding.docs
        .map((e) {
          if (e['productId'] != productId) {
            final dbEmbeddings = List<double>.from(e['embeddings']);
            final similarity = cosineSimilarity(productEmbedding, dbEmbeddings);
            if (similarity > 0.7) {
              return {
                'productId': e['productId'],
                'score': similarity,
                'embeddings': dbEmbeddings,
              };
            }
          }
        })
        .where((e) => e != null)
        .toList();
    if (results.isNotEmpty) {
      results.sort((a, b) => b!['score'].compareTo(a!['score']));
      final List<String> productIds =
          results.map((e) => e!['productId'] as String).toList();
      return productIds;
    }
    return [];
  }

  Future<List<Product>> getRecommendations(String productId) async {
    final productsIds = await fetchRecommendedProducts(productId);
    print(productsIds);
    // final user = await _userService.fetchUserInfo(userId);
    // final viewedProducts = user.viewedProducts;
    // viewedProducts.sort((a, b) => b.viewedAt!.compareTo(a.viewedAt!));
    // final productsIds =
    //     viewedProducts.map((e) => e.productId).toList().take(10).toList();

    // final cart = await _cartService.getCartByUserId(userId);
    // if (cart != null) {
    //   if (cart.shops.isNotEmpty) {
    //     final cartShop = cart.shops[0];
    //     for (var item in cartShop.items.values) {
    //       productsIds.add(item.productId);
    //     }
    //   }
    // }
    if (productsIds.isNotEmpty) {
      final products =
          await _productService.fetchProductsByListProductId(productsIds);
      return products;
    }
    return [];
    // final recommendations = <Product>[];
    // for (var p in products) {
    //   final similarSnapshot = await _firestore
    //       .collection('products')
    //       .where('category', isEqualTo: p.category)
    //       .where('isHidden', isEqualTo: false)
    //       .where('isDeleted', isEqualTo: false)
    //       .get();

    //   for (var doc in similarSnapshot.docs) {
    //     final product = await _productService.fetchProductByProductId(doc.id);
    //     if (!recommendations.any((e) => e.id == product.id)) {
    //       recommendations.add(product);
    //     }
    //   }
    // }

    // return recommendations.where((e) => e.getMaxOptionStock() > 0).toList();
  }
}
