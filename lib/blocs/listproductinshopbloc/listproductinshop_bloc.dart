import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_event.dart';
import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_state.dart';
import 'package:luanvan/services/product_service.dart';

class ListproductinshopBloc
    extends Bloc<ListproductinshopEvent, ListproductinshopState> {
  final ProductService _productService;
  ListproductinshopBloc(this._productService)
      : super(ListProductInShopInitial()) {
    on<FetchListproductinshopEventByShopId>(_onFetchListProductInShopByShopId);
  }

  Future<void> _onFetchListProductInShopByShopId(
      FetchListproductinshopEventByShopId event,
      Emitter<ListproductinshopState> emit) async {
    emit(ListProductInShopLoading());
    try {
      final listProduct =
          await _productService.fetchProductByShopId(event.shopId);
      emit(ListProducInShoptLoaded(listProduct));
    } catch (e) {
      emit(ListProductInShopError(e.toString()));
    }
  }
}
