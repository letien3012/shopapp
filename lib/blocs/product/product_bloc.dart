import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/product_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;
  ProductBloc(this._productService) : super(ProductInitial()) {
    on<FetchListProductEvent>(_onLoadProducts);
    on<FetchProductEventByShopId>(_onFetchProductByShopId);
    on<FetchProductEventByProductId>(_onFetchProductByProductId);
    on<AddProductEvent>(_onAddProduct);
    on<DeleteProductByIdEvent>(_onDeleteProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
  }

  void _onLoadProducts(
      FetchListProductEvent event, Emitter<ProductState> emit) {
    emit(ProductLoading());
    try {} catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFetchProductByShopId(
      FetchProductEventByShopId event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final listProduct =
          await _productService.fetchProductByShopId(event.shopId);
      emit(ListProductLoaded(listProduct));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
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
      await _productService.addProduct(event.product);
      emit(ProductLoaded(event.product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onDeleteProduct(
      DeleteProductByIdEvent event, Emitter<ProductState> emit) {}

  void _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) {}
}
