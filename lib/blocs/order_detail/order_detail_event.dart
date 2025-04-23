abstract class OrderDetailEvent {
  const OrderDetailEvent();
}

class FetchOrderByOrderId extends OrderDetailEvent {
  final String orderId;
  const FetchOrderByOrderId(this.orderId);
}
