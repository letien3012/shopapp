import 'package:bloc/bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/services/order_service.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;

  OrderBloc(this._orderService) : super(OrderInitial()) {
    on<FetchOrdersByUserId>(_onFetchOrdersByUserId);
    on<FetchOrdersByShopId>(_onFetchOrdersByShopId);
    on<FetchOrderById>(_onFetchOrderById);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<CancelOrder>(_onCancelOrder);
  }

  Future<void> _onFetchOrdersByUserId(
      FetchOrdersByUserId event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderService.fetchOrdersByUserId(event.userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrdersByShopId(
      FetchOrdersByShopId event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderService.fetchOrdersByShopId(event.shopId);
      emit(OrderShopLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrderById(
      FetchOrderById event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderService.fetchOrderById(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
      CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderService.createOrder(event.order);
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrder(
      UpdateOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await _orderService.updateOrder(event.order);
      emit(OrderUpdated(event.order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final updatedOrder = await _orderService.updateOrderStatus(
        event.orderId,
        event.newStatus,
        event.note,
      );
      emit(OrderDetailLoaded(updatedOrder));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCancelOrder(
      CancelOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final updatedOrder = await _orderService.cancelOrder(
        event.orderId,
        event.note,
      );
      emit(OrderDetailLoaded(updatedOrder));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
