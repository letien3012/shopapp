import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/recommendation_service.dart';
import 'package:luanvan/services/user_service.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  final CartService _cartService = CartService();
  final RecommendationService _recommendationService = RecommendationService();
  DocumentSnapshot? _lastDocument;
  void resetPagination() {
    _lastDocument = null;
  }

  List<String> getUniqueProductIds(List<String> productIds) {
    final seen = <String>{};
    final uniqueList = <String>[];

    for (final id in productIds) {
      if (!seen.contains(id)) {
        seen.add(id);
        uniqueList.add(id);
      }
    }

    return uniqueList;
  }

  Future<List<Product>> getAllProducts({int limit = 10, String? userId}) async {
    try {
      print(_lastDocument);
      if (userId != null) {
        final user = await _userService.fetchUserInfo(userId);
        final viewedProducts = user.viewedProducts;
        viewedProducts.sort((a, b) => b.viewedAt!.compareTo(a.viewedAt!));
        List<String> productsIds = [];
        productsIds.addAll(
            viewedProducts.map((e) => e.productId).toList().take(10).toList());
        List<String> allProductIds = [];
        final cart = await _cartService.getCartByUserId(userId);
        if (cart != null) {
          if (cart.shops.isNotEmpty) {
            final cartShop = cart.shops[0];
            for (var item in cartShop.items.values) {
              productsIds.add(item.productId);
            }
          }
        }
        if (productsIds.isNotEmpty) {
          allProductIds.addAll(productsIds);
          for (var productId in productsIds) {
            allProductIds.addAll(await _recommendationService
                .fetchRecommendedProducts(productId));
          }

          final productIdsNotDuplicate = getUniqueProductIds(allProductIds);
          final products = await _productService
              .fetchProductsByListProductId(productIdsNotDuplicate);

          return products.where((e) => e.getMaxOptionStock() > 0).toList();
        }
      }
      final List<Product> listProduct = [];
      Query query = _firestore
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('isHidden', isEqualTo: false)
          .orderBy('quantitySold', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final productSnapshot = await query.get();
      if (productSnapshot.docs.isNotEmpty) {
        for (var doc in productSnapshot.docs) {
          listProduct
              .add(await _productService.fetchProductByProductId(doc.id));
        }
        _lastDocument = productSnapshot.docs.last;
      } else {
        print("Product not found!");
      }
      // listProduct.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
      return listProduct
          .where((product) => product.getMaxOptionStock() > 0)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Product>> getRecommendedProducts(String userId,
      {int limit = 10}) async {
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
