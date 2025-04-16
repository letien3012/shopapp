import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/productcomment/product_comment_event.dart';
import 'package:luanvan/blocs/productcomment/product_comment_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/product_service.dart';

class ProductCommentBloc
    extends Bloc<ProductCommentEvent, ProductCommentState> {
  final ProductService _productService;
  ProductCommentBloc(
    this._productService,
  ) : super(ProductCommentInitial()) {
    on<ResetProductCommentEvent>(_onResetProductComment);
    on<FetchMultipleProductsCommentEvent>(_onFetchMultipleProducts);
  }
  void _onResetProductComment(
      ResetProductCommentEvent event, Emitter<ProductCommentState> emit) {
    emit(ProductCommentInitial());
  }

  Future<void> _onFetchMultipleProducts(FetchMultipleProductsCommentEvent event,
      Emitter<ProductCommentState> emit) async {
    try {
      emit(ProductCommentLoading());

      final List<Product> products =
          await _productService.fetchAllProduct(event.productIds);

      emit(ProductCommentListLoaded(products));
    } catch (e) {
      emit(ProductCommentError(e.toString()));
    }
  }
}
