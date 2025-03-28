import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:luanvan/models/order.dart';

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
          // .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders for shop: $e');
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return Order.fromMap({});
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

  Future<Order> createOrder(Order order) async {
    try {
      // Tạo tracking number mới
      final trackingNumber = await _generateUniqueTrackingNumber();

      final updatedOrder = order.copyWith(
        trackingNumber: trackingNumber,
      );

      final orderRef =
          await _firestore.collection('orders').add(updatedOrder.toMap());
      String orderId = orderRef.id;

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'id': orderId});

      final OrderCreated =
          await _firestore.collection('orders').doc(orderId).get();
      return Order.fromMap(OrderCreated.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      final orderRef = _firestore.collection('orders').doc(order.id);
      final orderData = order.toMap();
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
        'updateAt': updatedOrder.updateAt?.toIso8601String(),
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
        'updateAt': updatedOrder.updateAt?.toIso8601String(),
        'statusHistory':
            updatedOrder.statusHistory.map((e) => e.toMap()).toList(),
      });

      return updatedOrder;
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
