import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchListProductEvent>(_onLoadProducts);
    on<AddProductEvent>(_onAddProduct);
    on<DeleteProductByIdEvent>(_onDeleteProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
  }

  void _onLoadProducts(
      FetchListProductEvent event, Emitter<ProductState> emit) {}

  void _onAddProduct(AddProductEvent event, Emitter<ProductState> emit) {}

  void _onDeleteProduct(
      DeleteProductByIdEvent event, Emitter<ProductState> emit) {}

  void _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) {}
}
