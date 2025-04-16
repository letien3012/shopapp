import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/productdetail/productdetail_event.dart';
import 'package:luanvan/blocs/productdetail/productdetail_state.dart';
import 'package:luanvan/services/product_service.dart';

class ProductdetailBloc extends Bloc<ProductdetailEvent, ProductdetailState> {
  final ProductService _productService;
  ProductdetailBloc(this._productService) : super(ProductdetailInitial()) {
    on<FetchProductdetailEventByProductId>(_onFetchProductByProductId);
  }

  void _onResetProduct(ResetProductEvent event, Emitter<ProductState> emit) {
    emit(ProductInitial());
  }

  Future<void> _onFetchProductByProductId(
      FetchProductdetailEventByProductId event,
      Emitter<ProductdetailState> emit) async {
    emit(ProductdetailLoading());
    try {
      final product =
          await _productService.fetchProductByProductId(event.productId);

      emit(ProductdetailLoaded(product));
    } catch (e) {
      emit(ProductdetailError(e.toString()));
    }
  }
}
