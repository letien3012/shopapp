import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_event.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/product_service.dart';

class ProductOrderBloc extends Bloc<ProductOrderEvent, ProductOrderState> {
  final ProductService _productService;
  ProductOrderBloc(
    this._productService,
  ) : super(ProductOrderInitial()) {
    on<ResetProductOrderEvent>(_onResetProductOrder);
    on<FetchMultipleProductsOrderEvent>(_onFetchMultipleProducts);
  }
  void _onResetProductOrder(
      ResetProductOrderEvent event, Emitter<ProductOrderState> emit) {
    emit(ProductOrderInitial());
  }

  Future<void> _onFetchMultipleProducts(FetchMultipleProductsOrderEvent event,
      Emitter<ProductOrderState> emit) async {
    try {
      emit(ProductOrderLoading());

      final List<Product> products =
          await _productService.fetchProductsByListProductId(event.productIds);

      emit(ProductOrderListLoaded(products));
    } catch (e) {
      emit(ProductOrderError(e.toString()));
    }
  }
}
