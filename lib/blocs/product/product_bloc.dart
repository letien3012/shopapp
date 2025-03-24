import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
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
    on<UpdateProductEvent>(_onUpdateProduct);
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
      _listProductBloc.add(FetchListProductEventByShopId(event.product.shopId));
      emit(ProductInitial());
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
}
