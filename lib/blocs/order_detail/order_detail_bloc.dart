import 'package:bloc/bloc.dart';
import 'package:luanvan/blocs/order_detail/order_detail_event.dart';
import 'package:luanvan/blocs/order_detail/order_detail_state.dart';
import 'package:luanvan/services/order_service.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderService _orderService;

  OrderDetailBloc(this._orderService) : super(OrderDetailInitial()) {
    on<FetchOrderByOrderId>(_onFetchOrderByOrderId);
  }

  Future<void> _onFetchOrderByOrderId(
      FetchOrderByOrderId event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    try {
      final order = await _orderService.fetchOrderById(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderDetailError(e.toString()));
    }
  }
}
