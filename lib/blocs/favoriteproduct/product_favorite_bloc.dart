import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_event.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_state.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_event.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_state.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/user_service.dart';

class ProductFavoriteBloc
    extends Bloc<ProductFavoriteEvent, ProductFavoriteState> {
  final UserService _userService;
  final ProductService _productService;
  ProductFavoriteBloc(this._userService, this._productService)
      : super(ProductFavoriteInitial()) {
    on<AddFavoriteProductEvent>(_onAddFavoriteProduct);
    on<RemoveFavoriteProductEvent>(_onRemoveFavoriteProduct);
    on<FetchFavoriteProductEvent>(_onFetchFavoriteProduct);
  }

  Future<void> _onAddFavoriteProduct(
      AddFavoriteProductEvent event, Emitter<ProductFavoriteState> emit) async {
    emit(ProductFavoriteLoading());
    try {
      await _userService.addFavoriteProduct(event.productId, event.userId);
      emit(ProductFavoriteAdded());
    } catch (e) {
      emit(ProductFavoriteError(e.toString()));
    }
  }

  Future<void> _onRemoveFavoriteProduct(RemoveFavoriteProductEvent event,
      Emitter<ProductFavoriteState> emit) async {
    emit(ProductFavoriteLoading());
    try {
      await _userService.removeFavoriteProduct(event.productId, event.userId);
      emit(ProductFavoriteRemoved());
    } catch (e) {
      emit(ProductFavoriteError(e.toString()));
    }
  }

  Future<void> _onFetchFavoriteProduct(FetchFavoriteProductEvent event,
      Emitter<ProductFavoriteState> emit) async {
    emit(ProductFavoriteLoading());
    try {
      final listProductId =
          await _userService.fetchFavoriteProduct(event.userId);
      final listProduct =
          await _productService.fetchProductsByListProductId(listProductId);
      emit(ProductFavoriteLoaded(listProduct));
    } catch (e) {
      emit(ProductFavoriteError(e.toString()));
    }
  }
}
