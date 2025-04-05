import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:luanvan/models/order.dart';
import 'dart:math';

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

  // Tạo mã tracking number theo format YYMMDDXXXXXXXX (X là ký tự từ 0-9 và A-Z)
  Future<String> _generateUniqueTrackingNumber() async {
    String generateTrackingNumber() {
      final now = DateTime.now();
      final datePrefix =
          '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final random = List.generate(
          8,
          (index) =>
              chars[DateTime.now().millisecondsSinceEpoch % chars.length]);

      return datePrefix + random.join('');
    }

    while (true) {
      final trackingNumber = generateTrackingNumber();

      // Kiểm tra xem mã đã tồn tại chưa
      final querySnapshot = await _firestore
          .collection('orders')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return trackingNumber;
      }
    }
  }

  Future<List<Order>> createOrder(List<Order> orders) async {
    try {
      List<Order> createdOrders = [];

      for (var order in orders) {
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
        final orderRef =
            await _firestore.collection('orders').add(updatedOrder.toMap());
        final orderData = updatedOrder.toMap();
        orderData['id'] = orderRef.id;
        await orderRef.update({'id': orderRef.id});

        createdOrders.add(Order.fromMap(orderData));
      }

      return createdOrders;
    } catch (e) {
      throw Exception('Failed to create order: $e');
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
