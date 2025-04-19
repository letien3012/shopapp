import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/services/product_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;
  final ListProductBloc _listProductBloc;
  ProductBloc(this._productService, this._listProductBloc)
      : super(ProductInitial()) {
    on<FetchProductEventByProductId>(_onFetchProductByProductId);
    on<AddProductEvent>(_onAddProduct);
    on<DeleteProductByIdEvent>(_onDeleteProduct);
    on<UpdateProductViewCountEvent>(_onUpdateProductViewCount);
    on<IncrementProductFavoriteCountEvent>(_onIncrementProductFavoriteCount);
    on<DecrementProductFavoriteCountEvent>(_onDecrementProductFavoriteCount);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<ResetProductEvent>(_onResetProduct);
  }
  void _onResetProduct(ResetProductEvent event, Emitter<ProductState> emit) {
    emit(ProductInitial());
  }

  Future<void> _onFetchProductByProductId(
      FetchProductEventByProductId event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product =
          await _productService.fetchProductByProductId(event.productId);

      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final productId = await _productService.addProduct(event.product);
      _listProductBloc.add(FetchListProductEventByShopId(event.product.shopId));
      emit(ProductCreated(productId));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onDeleteProduct(
      DeleteProductByIdEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product =
          await _productService.fetchProductByProductId(event.productId);
      await _productService.deleteProduct(event.productId);
      _listProductBloc.add(FetchListProductEventByShopId(product.shopId));
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onUpdateProduct(
      UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await _productService.UpdateProduct(event.product);
      // final listproduct =
      //     await _productService.fetchProductByShopId(event.product.shopId);
      _listProductBloc.add(FetchListProductEventByShopId(event.product.shopId));
      await Future.delayed(Duration(milliseconds: 100));
      emit(ProductLoaded(event.product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onUpdateProductViewCount(
      UpdateProductViewCountEvent event, Emitter<ProductState> emit) async {
    try {
      await _productService.updateProductViewCount(event.productId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onIncrementProductFavoriteCount(
      IncrementProductFavoriteCountEvent event,
      Emitter<ProductState> emit) async {
    try {
      await _productService.incrementProductFavoriteCount(event.productId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onDecrementProductFavoriteCount(
      DecrementProductFavoriteCountEvent event,
      Emitter<ProductState> emit) async {
    try {
      await _productService.decrementProductFavoriteCount(event.productId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
