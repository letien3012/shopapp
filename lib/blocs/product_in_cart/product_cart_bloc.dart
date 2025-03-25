import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_event.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/product_service.dart';

class ProductCartBloc extends Bloc<ProductCartEvent, ProductCartState> {
  final ProductService _productService;
  ProductCartBloc(
    this._productService,
  ) : super(ProductCartInitial()) {
    on<ResetProductCartEvent>(_onResetProductCart);
    on<FetchMultipleProductsEvent>(_onFetchMultipleProducts);
  }
  void _onResetProductCart(
      ResetProductCartEvent event, Emitter<ProductCartState> emit) {
    emit(ProductCartInitial());
  }

  Future<void> _onFetchMultipleProducts(
      FetchMultipleProductsEvent event, Emitter<ProductCartState> emit) async {
    try {
      emit(ProductCartLoading());

      final List<Product> products =
          await _productService.fetchProductsByListProductId(event.productIds);

      emit(ProductCartListLoaded(products));
    } catch (e) {
      emit(ProductCartError(e.toString()));
    }
  }
}
