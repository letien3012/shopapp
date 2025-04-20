import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';
import 'package:luanvan/models/option_info.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'dart:math';

import '../models/cart.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore;

  OrderService({firestore.FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? firestore.FirebaseFirestore.instance;

  Future<List<Order>> fetchOrdersByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          // .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders for user: $e');
    }
  }

  Future<List<Order>> fetchOrdersByShopId(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('shopId', isEqualTo: shopId)
          .get();
      return querySnapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch orders for shop: $e');
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return Order.fromMap(doc.data()!);
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<String> _generateUniqueTrackingNumber() async {
    String generateTrackingNumber() {
      final now = DateTime.now();
      final datePrefix =
          '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      // Tạo 8 ký tự ngẫu nhiên từ chữ và số
      final random = Random();
      const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final randomChars =
          List.generate(8, (index) => chars[random.nextInt(chars.length)]);

      return datePrefix + randomChars.join('');
    }

    while (true) {
      final trackingNumber = generateTrackingNumber();

      // Kiểm tra xem tracking number đã tồn tại chưa
      final querySnapshot = await _firestore
          .collection('orders')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return trackingNumber;
      }
    }
  }

  Future<Product> _fetchProductWithSubcollections(
      firestore.DocumentSnapshot doc) async {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final List<ProductVariant> variants = [];

    // Fetch variants
    final variantsSnapshot = await doc.reference.collection('variants').get();

    // Chuyển đổi thành list và sắp xếp theo variantIndex
    final variantsList = variantsSnapshot.docs.toList();
    variantsList.sort((a, b) {
      final aIndex = (a.data()['variantIndex'] as num?)?.toInt() ?? 0;
      final bIndex = (b.data()['variantIndex'] as num?)?.toInt() ?? 0;
      return aIndex.compareTo(bIndex);
    });

    for (var variantDoc in variantsList) {
      final variantData = variantDoc.data() as Map<String, dynamic>;
      final List<ProductOption> options = [];

      // Fetch options for each variant
      final optionsSnapshot =
          await variantDoc.reference.collection('options').get();

      // Chuyển đổi options thành list và sắp xếp theo optionIndex
      final optionsList = optionsSnapshot.docs.toList();
      optionsList.sort((a, b) {
        final aIndex = (a.data()['optionIndex'] as num?)?.toInt() ?? 0;
        final bIndex = (b.data()['optionIndex'] as num?)?.toInt() ?? 0;
        return aIndex.compareTo(bIndex);
      });

      for (var optionDoc in optionsList) {
        final optionData = optionDoc.data() as Map<String, dynamic>;
        options.add(ProductOption.fromMap({
          ...optionData,
          'id': optionDoc.id,
        }));
      }

      variants.add(ProductVariant(
        id: variantDoc.id,
        label: variantData['label'] as String,
        options: options,
        variantIndex: variantData['variantIndex'] as int? ?? 0,
      ));
    }

    return Product.fromMap({
      ...data,
      'id': doc.id,
      'variants': variants.map((v) => v.toMap()).toList(),
    });
  }

  Future<Order> createOrder(
      Order order, Cart cart, List<String> listItemId) async {
    try {
      // Tạo tracking number mới cho mỗi order
      String trackingNumber = await _generateUniqueTrackingNumber();
      bool isUnique = false;

      while (!isUnique) {
        // Kiểm tra xem tracking number đã tồn tại chưa
        final querySnapshot = await _firestore
            .collection('orders')
            .where('trackingNumber', isEqualTo: trackingNumber)
            .get();
        isUnique = querySnapshot.docs.isEmpty;
        if (!isUnique) {
          trackingNumber = await _generateUniqueTrackingNumber();
        }
      }

      final updatedOrder = order.copyWith(trackingNumber: trackingNumber);
      final orderRef = _firestore.collection('orders').doc();
      final updatedOrderWithId = updatedOrder.copyWith(id: orderRef.id);
      await _firestore.runTransaction((transaction) async {
        final productIds =
            updatedOrderWithId.item.map((e) => e.productId).toList();
        final productSnapshot = await _firestore
            .collection('products')
            .where('id', whereIn: productIds)
            .get();
        final productList = await Future.wait(productSnapshot.docs
            .map((doc) => _fetchProductWithSubcollections(doc)));
        final listProductUpdate = [];
        final cartShop = cart.getShop(order.shopId);
        if (cartShop == null) throw Exception();
        for (var itemId in listItemId) {
          final cartItem = cartShop.items[itemId];
          if (cartItem == null) continue;
          var product = productList.firstWhere(
            (p) => p.id == cartItem.productId,
          );
          if (product.isDeleted || product.isHidden) {
            throw Exception('Sản phẩm đã bị xóa hoặc ẩn');
          }
          if (product.variants.isEmpty) {
            if (product.quantity! - cartItem.quantity < 0) {
              throw Exception('Sản phẩm ${product.name} không còn hàng');
            }
            product = product.copyWith(
              quantity: product.quantity! - cartItem.quantity,
              quantitySold: product.quantitySold + cartItem.quantity,
            );
            listProductUpdate.add(product);
          } else if (product.variants.length == 1) {
            int i = product.variants[0].options
                .indexWhere((element) => element.id == cartItem.optionId1);
            if (i == -1) i = 0;
            if (product.optionInfos[i].stock - cartItem.quantity < 0) {
              throw Exception('Sản phẩm ${product.name} không còn hàng');
            }
            OptionInfo optionInfo = product.optionInfos[i].copyWith(
              stock: product.optionInfos[i].stock - cartItem.quantity,
            );
            product = product.copyWith(
                optionInfos: [...product.optionInfos]..[i] = optionInfo,
                quantitySold: product.quantitySold + cartItem.quantity);
            listProductUpdate.add(product);
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
                throw Exception('Sản phẩm ${product.name} không còn hàng');
              }
              OptionInfo optionInfo =
                  product.optionInfos[optionInfoIndex].copyWith(
                stock: product.optionInfos[optionInfoIndex].stock -
                    cartItem.quantity,
              );
              product = product.copyWith(
                  optionInfos: [...product.optionInfos]..[optionInfoIndex] =
                      optionInfo,
                  quantitySold: product.quantitySold + cartItem.quantity);
              listProductUpdate.add(product);
            }
          }

          final updatedItems = Map<String, CartItem>.from(cartShop.items);
          for (var itemId in listItemId) {
            updatedItems.remove(itemId);
          }
          if (updatedItems.isEmpty) {
            // Nếu không còn sản phẩm nào, xóa shop khỏi giỏ hàng
            final updatedShops = List<CartShop>.from(cart.shops);
            updatedShops.removeWhere((shop) => shop.shopId == shop.shopId);

            cart = cart.copyWith(shops: updatedShops);
          } else {
            // Cập nhật lại shop với các sản phẩm còn lại
            final updatedShop = cartShop.copyWith(items: updatedItems);
            final updatedShops = List<CartShop>.from(cart.shops);
            final shopIndex =
                updatedShops.indexWhere((shop) => shop.shopId == shop.shopId);
            if (shopIndex != -1) {
              updatedShops[shopIndex] = updatedShop;
            }
            cart = cart.copyWith(shops: updatedShops);
          }
        }
        transaction.set(orderRef, updatedOrderWithId.toMap());
        for (var product in listProductUpdate) {
          final productRef = _firestore.collection('products').doc(product.id);
          transaction.update(productRef, product.toMap());
        }
        transaction.update(
            _firestore.collection('carts').doc(cart.id), cart.toMap());
      });

      return updatedOrderWithId;
    } catch (e) {
      throw Exception('Lỗi khi tạo đơn hàng: $e');
    }
  }

  String _generateShippingCode(String shippingMethod) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomChars =
        List.generate(7, (index) => chars[random.nextInt(chars.length)]).join();
    return shippingMethod == 'Nhanh' ? 'GHN$randomChars' : 'GHTK$randomChars';
  }

  Future<void> updateOrder(Order order) async {
    try {
      final orderRef = _firestore.collection('orders').doc(order.id);
      final orderData = order.toMap();
      // Generate shipping code only when status is processing
      if (order.status == OrderStatus.shipped &&
          (order.shippingCode == null || order.shippingCode!.isEmpty)) {
        String shippingCode = _generateShippingCode(order.shipMethod.name);
        bool isUnique = false;

        while (!isUnique) {
          // Check if shipping code exists
          final querySnapshot = await _firestore
              .collection('orders')
              .where('shippingCode', isEqualTo: shippingCode)
              .get();

          isUnique = querySnapshot.docs.isEmpty;
          if (!isUnique) {
            shippingCode = _generateShippingCode(order.shipMethod.name);
          }
        }

        orderData['shippingCode'] = shippingCode;
      }

      await orderRef.update(orderData);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<Order> updateOrderStatus(
      String orderId, OrderStatus newStatus, String? note) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      final doc = await orderRef.get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }

      final currentOrder = Order.fromMap(
        doc.data()!,
      );
      final updatedOrder = currentOrder.updateStatus(newStatus, note: note);

      await orderRef.update({
        'status': updatedOrder.status.toString().split('.').last,
        'updateAt': updatedOrder.updateAt != null
            ? firestore.Timestamp.fromDate(updatedOrder.updateAt!)
            : null,
        'statusHistory':
            updatedOrder.statusHistory.map((e) => e.toMap()).toList(),
      });
      if (newStatus == OrderStatus.delivered) {
        await orderRef.update({
          'actualDeliveryDate': firestore.Timestamp.fromDate(DateTime.now()),
        });
      }
      if (newStatus == OrderStatus.returned) {
        final order = Order.fromMap(doc.data()!);
        final productIds = order.item.map((e) => e.productId).toList();
        final productSnapshot = await _firestore
            .collection('products')
            .where('id', whereIn: productIds)
            .get();
        final productList = await Future.wait(productSnapshot.docs
            .map((doc) => _fetchProductWithSubcollections(doc)));
        final listProductUpdate = [];

        for (var item in order.item) {
          var product = productList.firstWhere(
            (p) => p.id == item.productId,
          );

          if (product.variants.isEmpty) {
            product = product.copyWith(
              quantity: product.quantity! + item.quantity,
              quantitySold: product.quantitySold - item.quantity,
            );
            listProductUpdate.add(product);
          } else if (product.variants.length == 1) {
            int i = product.variants[0].options
                .indexWhere((element) => element.id == item.optionId1);
            if (i == -1) i = 0;
            if (product.optionInfos[i].stock - item.quantity < 0) {
              throw Exception('Sản phẩm ${product.name} không còn hàng');
            }
            OptionInfo optionInfo = product.optionInfos[i].copyWith(
              stock: product.optionInfos[i].stock + item.quantity,
            );
            product = product.copyWith(
                optionInfos: [...product.optionInfos]..[i] = optionInfo,
                quantitySold: product.quantitySold - item.quantity);
            listProductUpdate.add(product);
          } else if (product.variants.length > 1) {
            int i = product.variants[0].options
                .indexWhere((opt) => opt.id == item.optionId1);
            int j = product.variants[1].options
                .indexWhere((opt) => opt.id == item.optionId2);
            if (i == -1) i = 0;
            if (j == -1) j = 0;
            int optionInfoIndex = i * product.variants[1].options.length + j;
            if (optionInfoIndex < product.optionInfos.length) {
              OptionInfo optionInfo =
                  product.optionInfos[optionInfoIndex].copyWith(
                stock:
                    product.optionInfos[optionInfoIndex].stock + item.quantity,
              );
              product = product.copyWith(
                  optionInfos: [...product.optionInfos]..[optionInfoIndex] =
                      optionInfo,
                  quantitySold: product.quantitySold - item.quantity);
              listProductUpdate.add(product);
            }
          }
        }
        for (var product in listProductUpdate) {
          final productRef = _firestore.collection('products').doc(product.id);
          await productRef.update(product.toMap());
        }
      }
      return updatedOrder;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<Order> cancelOrder(String orderId, String? note) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      final doc = await orderRef.get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      final order = Order.fromMap(doc.data()!);
      final productIds = order.item.map((e) => e.productId).toList();
      final productSnapshot = await _firestore
          .collection('products')
          .where('id', whereIn: productIds)
          .get();
      final productList = await Future.wait(productSnapshot.docs
          .map((doc) => _fetchProductWithSubcollections(doc)));
      final listProductUpdate = [];

      for (var item in order.item) {
        var product = productList.firstWhere(
          (p) => p.id == item.productId,
        );

        if (product.variants.isEmpty) {
          product = product.copyWith(
            quantity: product.quantity! + item.quantity,
            quantitySold: product.quantitySold - item.quantity,
          );
          listProductUpdate.add(product);
        } else if (product.variants.length == 1) {
          int i = product.variants[0].options
              .indexWhere((element) => element.id == item.optionId1);
          if (i == -1) i = 0;
          if (product.optionInfos[i].stock - item.quantity < 0) {
            throw Exception('Sản phẩm ${product.name} không còn hàng');
          }
          OptionInfo optionInfo = product.optionInfos[i].copyWith(
            stock: product.optionInfos[i].stock + item.quantity,
          );
          product = product.copyWith(
              optionInfos: [...product.optionInfos]..[i] = optionInfo,
              quantitySold: product.quantitySold - item.quantity);
          listProductUpdate.add(product);
        } else if (product.variants.length > 1) {
          int i = product.variants[0].options
              .indexWhere((opt) => opt.id == item.optionId1);
          int j = product.variants[1].options
              .indexWhere((opt) => opt.id == item.optionId2);
          if (i == -1) i = 0;
          if (j == -1) j = 0;
          int optionInfoIndex = i * product.variants[1].options.length + j;
          if (optionInfoIndex < product.optionInfos.length) {
            OptionInfo optionInfo =
                product.optionInfos[optionInfoIndex].copyWith(
              stock: product.optionInfos[optionInfoIndex].stock + item.quantity,
            );
            product = product.copyWith(
                optionInfos: [...product.optionInfos]..[optionInfoIndex] =
                    optionInfo,
                quantitySold: product.quantitySold - item.quantity);
            listProductUpdate.add(product);
          }
        }
      }
      for (var product in listProductUpdate) {
        final productRef = _firestore.collection('products').doc(product.id);
        await productRef.update(product.toMap());
      }
      final currentOrder = Order.fromMap(
        doc.data()!,
      );
      final updatedOrder =
          currentOrder.updateStatus(OrderStatus.cancelled, note: note);

      await orderRef.update({
        'status': updatedOrder.status.toString().split('.').last,
        'updateAt': updatedOrder.updateAt != null
            ? firestore.Timestamp.fromDate(updatedOrder.updateAt!)
            : null,
        'statusHistory':
            updatedOrder.statusHistory.map((e) => e.toMap()).toList(),
      });

      return updatedOrder;
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
