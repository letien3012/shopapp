import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_event.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/product_service.dart';

class ProductSearchImageBloc
    extends Bloc<ProductSearchImageEvent, ProductSearchImageState> {
  final ProductService _productService;
  ProductSearchImageBloc(
    this._productService,
  ) : super(ProductSearchImageInitial()) {
    on<ResetProductSearchImageEvent>(_onResetProductSearchImage);
    on<FetchMultipleProductsSearchImageEvent>(_onFetchMultipleProducts);
  }
  void _onResetProductSearchImage(ResetProductSearchImageEvent event,
      Emitter<ProductSearchImageState> emit) {
    emit(ProductSearchImageInitial());
  }

  Future<void> _onFetchMultipleProducts(
      FetchMultipleProductsSearchImageEvent event,
      Emitter<ProductSearchImageState> emit) async {
    try {
      emit(ProductSearchImageLoading());

      final List<Product> products =
          await _productService.fetchProductsByListProductId(event.productIds);
      emit(ProductSearchImageListLoaded(products));
    } catch (e) {
      emit(ProductSearchImageError(e.toString()));
    }
  }
}
