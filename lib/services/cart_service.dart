import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/cart.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Cart?> getCartByUserId(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        return Cart.fromFirestore(
            docSnapshot.docs.first.data(), docSnapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy giỏ hàng: $e');
    }
  }

  Future<void> addProductToCart(
      String userId, String productId, int quantity, String shopId,
      {int? variantIndex, int? optionIndex}) async {
    try {
      final cart = await getCartByUserId(userId);

      if (cart == null) {
        // Tạo giỏ hàng mới nếu chưa tồn tại
        final newCart = Cart(
          id: userId,
          userId: userId,
          productIdAndQuantity: {productId: quantity},
          listShopId: [shopId],
          productVariantIndexes:
              variantIndex != null ? {productId: variantIndex} : {},
          productOptionIndexes:
              optionIndex != null ? {productId: optionIndex} : {},
        );
        await updateCart(newCart);
        return;
      }

      // Cập nhật số lượng sản phẩm
      final updatedProducts = Map<String, int>.from(cart.productIdAndQuantity);
      if (updatedProducts.containsKey(productId)) {
        updatedProducts[productId] = updatedProducts[productId]! + quantity;
      } else {
        updatedProducts[productId] = quantity;
      }

      // Cập nhật danh sách shop
      final updatedShops = List<String>.from(cart.listShopId);
      if (!updatedShops.contains(shopId)) {
        updatedShops.add(shopId);
      }

      // Cập nhật chỉ số biến thể và tùy chọn
      final updatedVariantIndexes =
          Map<String, int>.from(cart.productVariantIndexes);
      final updatedOptionIndexes =
          Map<String, int>.from(cart.productOptionIndexes);

      if (variantIndex != null) {
        updatedVariantIndexes[productId] = variantIndex;
      }

      if (optionIndex != null) {
        updatedOptionIndexes[productId] = optionIndex;
      }

      final updatedCart = cart.copyWith(
        productIdAndQuantity: updatedProducts,
        listShopId: updatedShops,
        productVariantIndexes: updatedVariantIndexes,
        productOptionIndexes: updatedOptionIndexes,
      );

      print(updatedCart);
      await updateCart(updatedCart);
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm vào giỏ hàng: $e');
    }
  }

  Future<void> updateCart(Cart cart) async {
    try {
      await _firestore.collection('carts').doc(cart.id).set(cart.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giỏ hàng: $e');
    }
  }

  Future<void> removeProductFromCart(String userId, String productId) async {
    try {
      final cart = await getCartByUserId(userId);
      if (cart != null) {
        final updatedProducts =
            Map<String, int>.from(cart.productIdAndQuantity);
        updatedProducts.remove(productId);

        // Cũng xóa chỉ số biến thể và tùy chọn
        final updatedVariantIndexes =
            Map<String, int>.from(cart.productVariantIndexes);
        final updatedOptionIndexes =
            Map<String, int>.from(cart.productOptionIndexes);

        updatedVariantIndexes.remove(productId);
        updatedOptionIndexes.remove(productId);

        final updatedCart = cart.copyWith(
          productIdAndQuantity: updatedProducts,
          productVariantIndexes: updatedVariantIndexes,
          productOptionIndexes: updatedOptionIndexes,
        );

        await updateCart(updatedCart);
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm khỏi giỏ hàng: $e');
    }
  }

  Future<void> updateProductQuantity(
      String userId, String productId, int quantity) async {
    try {
      final cart = await getCartByUserId(userId);
      if (cart != null) {
        final updatedProducts =
            Map<String, int>.from(cart.productIdAndQuantity);
        if (updatedProducts.containsKey(productId)) {
          updatedProducts[productId] = quantity;
          final updatedCart =
              cart.copyWith(productIdAndQuantity: updatedProducts);
          await updateCart(updatedCart);
        } else {
          throw Exception('Sản phẩm không tồn tại trong giỏ hàng');
        }
      } else {
        throw Exception('Giỏ hàng không tồn tại');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng sản phẩm: $e');
    }
  }

  Future<void> updateProductVariantOption(String userId, String productId,
      int variantIndex, int optionIndex) async {
    try {
      final cart = await getCartByUserId(userId);
      if (cart != null) {
        // Kiểm tra xem sản phẩm có tồn tại trong giỏ hàng không
        if (cart.productIdAndQuantity.containsKey(productId)) {
          // Cập nhật chỉ số biến thể và tùy chọn
          final updatedVariantIndexes =
              Map<String, int>.from(cart.productVariantIndexes);
          final updatedOptionIndexes =
              Map<String, int>.from(cart.productOptionIndexes);

          updatedVariantIndexes[productId] = variantIndex;
          updatedOptionIndexes[productId] = optionIndex;

          final updatedCart = cart.copyWith(
            productVariantIndexes: updatedVariantIndexes,
            productOptionIndexes: updatedOptionIndexes,
          );

          await updateCart(updatedCart);
        } else {
          throw Exception('Sản phẩm không tồn tại trong giỏ hàng');
        }
      } else {
        throw Exception('Giỏ hàng không tồn tại');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật biến thể và tùy chọn sản phẩm: $e');
    }
  }
}
