import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/services/cart_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc(this._cartService) : super(CartInitial()) {
    on<FetchCartEventUserId>(_onLoadCart);
    on<AddCartEvent>(_onAddCart);
    on<DeleteProductCartEvent>(_onDeleteCartProduct);
    on<UpdateCartEvent>(_onUpdateProduct);
    on<UpdateProductVariantEvent>(_onUpdateProductVariant);
  }

  Future<void> _onLoadCart(
      FetchCartEventUserId event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartService.getCartByUserId(event.userId);
      if (cart != null) {
        emit(CartLoaded(cart));
      } else {
        final newCart = Cart(
            id: event.userId,
            userId: event.userId,
            productIdAndQuantity: {},
            listShopId: [],
            productOptionIndexes: {},
            productVariantIndexes: {});
        emit(CartLoaded(newCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddCart(AddCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await _cartService.addProductToCart(
          event.userId, event.productId, event.quantity, event.shopId,
          variantIndex: event.variantIndex, optionIndex: event.optionIndex);

      final cart = await _cartService.getCartByUserId(event.userId);
      emit(CartLoaded(cart!));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onDeleteCartProduct(
      DeleteProductCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final updatedProducts =
            Map<String, int>.from(currentState.cart.productIdAndQuantity);
        updatedProducts.remove(event.productId);

        // Cập nhật cả productVariantIndexes và productOptionIndexes
        final updatedVariantIndexes =
            Map<String, int>.from(currentState.cart.productVariantIndexes);
        final updatedOptionIndexes =
            Map<String, int>.from(currentState.cart.productOptionIndexes);

        updatedVariantIndexes.remove(event.productId);
        updatedOptionIndexes.remove(event.productId);

        final updatedCart = currentState.cart.copyWith(
            productIdAndQuantity: updatedProducts,
            productVariantIndexes: updatedVariantIndexes,
            productOptionIndexes: updatedOptionIndexes);

        await _cartService.updateCart(updatedCart);
        emit(CartLoaded(updatedCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final updatedProducts =
            Map<String, int>.from(currentState.cart.productIdAndQuantity);

        if (updatedProducts.containsKey(event.productId)) {
          updatedProducts[event.productId] = event.quantity;

          Map<String, int> updatedVariantIndexes =
              Map<String, int>.from(currentState.cart.productVariantIndexes);
          Map<String, int> updatedOptionIndexes =
              Map<String, int>.from(currentState.cart.productOptionIndexes);

          if (event.variantIndex != null) {
            updatedVariantIndexes[event.productId] = event.variantIndex!;
          }

          if (event.optionIndex != null) {
            updatedOptionIndexes[event.productId] = event.optionIndex!;
          }

          final updatedCart = currentState.cart.copyWith(
              productIdAndQuantity: updatedProducts,
              productVariantIndexes: updatedVariantIndexes,
              productOptionIndexes: updatedOptionIndexes);

          await _cartService.updateCart(updatedCart);
          emit(CartLoaded(updatedCart));
        } else {
          emit(CartError("Sản phẩm không tồn tại trong giỏ hàng"));
        }
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateProductVariant(
      UpdateProductVariantEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        if (currentState.cart.productIdAndQuantity
            .containsKey(event.productId)) {
          final updatedVariantIndexes =
              Map<String, int>.from(currentState.cart.productVariantIndexes);
          final updatedOptionIndexes =
              Map<String, int>.from(currentState.cart.productOptionIndexes);

          updatedVariantIndexes[event.productId] = event.variantIndex;
          updatedOptionIndexes[event.productId] = event.optionIndex;

          final updatedCart = currentState.cart.copyWith(
              productVariantIndexes: updatedVariantIndexes,
              productOptionIndexes: updatedOptionIndexes);

          await _cartService.updateCart(updatedCart);
          emit(CartLoaded(updatedCart));
        } else {
          emit(CartError("Sản phẩm không tồn tại trong giỏ hàng"));
        }
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
