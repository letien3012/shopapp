import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_event.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_state.dart';
import 'package:luanvan/services/product_service.dart';

class ListProductByCategoryBloc
    extends Bloc<ListProductByCategoryEvent, ListProductByCategoryState> {
  final ProductService _productService;
  ListProductByCategoryBloc(this._productService)
      : super(ListProductByCategoryInitial()) {
    on<FetchListProductByCategoryEventByCategoryId>(
        _onFetchListProductByCategoryId);
  }

  Future<void> _onFetchListProductByCategoryId(
      FetchListProductByCategoryEventByCategoryId event,
      Emitter<ListProductByCategoryState> emit) async {
    emit(ListProductByCategoryLoading());
    try {
      final listProduct =
          await _productService.fetchProductByCategoryId(event.categoryId);
      emit(ListProductByCategoryLoaded(listProduct));
    } catch (e) {
      emit(ListProductByCategoryError(e.toString()));
    }
  }
}
