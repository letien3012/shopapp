import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/user_service.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  final CartService _cartService = CartService();

  Future<List<Product>> getAllProducts() async {
    try {
      final List<Product> listProduct = [];
      final productSnapshot = await _firestore
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('isHidden', isEqualTo: false)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        for (var doc in productSnapshot.docs) {
          listProduct
              .add(await _productService.fetchProductByProductId(doc.id));
        }
      } else {
        print("Product not found!");
      }
      listProduct.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
      return listProduct
          .where((product) =>
              !product.isDeleted &&
              !product.isHidden &&
              product.getMaxOptionStock() > 0)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Product>> getRecommendedProducts(String userId) async {
    try {
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

      if (productsIds.isEmpty) {
        return await getAllProducts();
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
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
