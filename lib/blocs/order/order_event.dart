import 'package:luanvan/models/order.dart';

abstract class OrderEvent {
  const OrderEvent();
}

class FetchOrdersByUserId extends OrderEvent {
  final String userId;
  const FetchOrdersByUserId(this.userId);
}

class FetchOrdersByShopId extends OrderEvent {
  final String shopId;
  const FetchOrdersByShopId(this.shopId);
}

class FetchOrderById extends OrderEvent {
  final String orderId;
  const FetchOrderById(this.orderId);
}

class CreateOrder extends OrderEvent {
  final Order order;
  const CreateOrder(this.order);
}

class UpdateOrder extends OrderEvent {
  final Order order;

  const UpdateOrder(this.order);
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String? note;
  const UpdateOrderStatus(this.orderId, this.newStatus, {this.note});
}

class CancelOrder extends OrderEvent {
  final String orderId;
  final String? note;
  const CancelOrder(this.orderId, {this.note});
}
