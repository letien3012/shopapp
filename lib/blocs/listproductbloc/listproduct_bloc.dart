import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/services/product_service.dart';

class ListProductBloc extends Bloc<ListProductEvent, ListProductState> {
  final ProductService _productService;
  ListProductBloc(this._productService) : super(ListProductInitial()) {
    on<FetchListProductEventByShopId>(_onFetchListProductByShopId);
  }

  Future<void> _onFetchListProductByShopId(FetchListProductEventByShopId event,
      Emitter<ListProductState> emit) async {
    emit(ListProductLoading());
    try {
      final listProduct =
          await _productService.fetchProductByShopId(event.shopId);
      emit(ListProductLoaded(listProduct));
    } catch (e) {
      emit(ListProductError(e.toString()));
    }
  }
}
