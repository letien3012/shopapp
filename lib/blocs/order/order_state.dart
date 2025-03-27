import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:luanvan/models/order.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final Order order;
  OrderCreated(this.order);
}

class OrderUpdated extends OrderState {
  final Order order;
  OrderUpdated(this.order);
}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  OrderLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final Order order;
  OrderDetailLoaded(this.order);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}
