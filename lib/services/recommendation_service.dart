import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/user_service.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  Future<List<Product>> getRecommendations(String userId) async {
    final user = await _userService.fetchUserInfo(userId);
    final viewedProducts = user.viewedProducts;
    viewedProducts.sort((a, b) => b.viewedAt!.compareTo(a.viewedAt!));
    final productsIds =
        viewedProducts.map((e) => e.productId).toList().take(10).toList();

    final cart = await _cartService.getCartByUserId(userId);
    if (cart != null) {
      if (cart.shops.isNotEmpty) {
        final cartShop = cart.shops[0];
        for (var item in cartShop.items.values) {
          productsIds.add(item.productId);
        }
      }
    }
    final products =
        await _productService.fetchProductsByListProductId(productsIds);

    final recommendations = <Product>[];
    for (var p in products) {
      final similarSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: p.category)
          .where('isHidden', isEqualTo: false)
          .where('isDeleted', isEqualTo: false)
          .get();

      for (var doc in similarSnapshot.docs) {
        final product = await _productService.fetchProductByProductId(doc.id);
        if (!recommendations.any((e) => e.id == product.id)) {
          recommendations.add(product);
        }
      }
    }

    return recommendations.where((e) => e.getMaxOptionStock() > 0).toList();
  }
}
