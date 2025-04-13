import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/services/product_service.dart';
import '../models/cart.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Cart?> getCartByUserId(String userId) async {
    final doc = await _firestore
        .collection('carts')
        .where('userId', isEqualTo: userId)
        .get();
    if (doc.docs.isNotEmpty) {
      final cart = Cart.fromMap(doc.docs.first.data());

      for (var shop in cart.shops) {
        for (var itemId in shop.items.keys) {
          final cartItem = shop.items[itemId];
          if (cartItem == null) {
            return null;
          } else {
            final productService = ProductService();
            final product = await productService
                .fetchProductByProductId(cartItem.productId);
            if (product.variants.isEmpty) {
              if (product.quantity! - cartItem.quantity < 0) {
                cartItem.quantity = product.quantity!;
              }
            } else if (product.variants.length > 1) {
              int i = product.variants[0].options
                  .indexWhere((opt) => opt.id == cartItem.optionId1);
              int j = product.variants[1].options
                  .indexWhere((opt) => opt.id == cartItem.optionId2);
              if (i == -1) i = 0;
              if (j == -1) j = 0;
              int optionInfoIndex = i * product.variants[1].options.length + j;
              if (optionInfoIndex < product.optionInfos.length) {
                if (product.optionInfos[optionInfoIndex].stock -
                        cartItem.quantity <
                    0) {
                  cartItem.quantity =
                      product.optionInfos[optionInfoIndex].stock;
                }
              }
            }
            shop.items[itemId] = cartItem;
          }
        }
        cart.copyWith(shops: [shop]);
      }
      await updateCart(cart);
      return cart;
    }
    return null;
  }

  Future<void> createCart(Cart cart) async {
    await _firestore.collection('carts').doc(cart.userId).set(cart.toMap());
  }

  Future<void> updateCart(Cart cart) async {
    await _firestore.collection('carts').doc(cart.id).update(cart.toMap());
  }

  Future<void> deleteCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }
}
