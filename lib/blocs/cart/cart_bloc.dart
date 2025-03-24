import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';
import 'package:luanvan/services/cart_service.dart';

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc(this._cartService) : super(CartInitial()) {
    on<FetchCartEventUserId>(_onLoadCart);
    on<AddCartEvent>(_onAddCart);
    on<UpdateCartEvent>(_onUpdateCart);
    on<DeleteCartProductEvent>(_onDeleteCartProduct);
    on<DeleteCartShopEvent>(_onDeleteCartShop);
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
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: event.userId,
          shops: [],
        );

        await _cartService.createCart(newCart);

        emit(CartLoaded(newCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddCart(AddCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final currentCart = await _cartService.getCartByUserId(event.userId);
      // Create new cart item
      final newItem = CartItem(
        productId: event.productId,
        quantity: event.quantity,
        variantId1: event.variantId1,
        optionId1: event.optionId1,
      );

      // Get or create shop
      final shop = currentCart!.getShop(event.shopId) ??
          CartShop(
            shopId: event.shopId,
            items: {},
          );
      print(shop.shopId);
      // Update shop items
      final updatedItems = Map<String, CartItem>.from(shop.items);
      if (updatedItems.containsKey(event.productId)) {
        final existingItem = updatedItems[event.productId]!;
        updatedItems[event.productId] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
        );
      } else {
        updatedItems[event.productId] = newItem;
      }

      // Update shop
      final updatedShop = shop.copyWith(items: updatedItems);

      // Update cart shops
      final updatedShops = List<CartShop>.from(currentCart.shops);
      final existingShopIndex =
          updatedShops.indexWhere((shop) => shop.shopId == event.shopId);

      if (existingShopIndex != -1) {
        // Update existing shop
        updatedShops[existingShopIndex] = updatedShop;
      } else {
        // Add new shop
        updatedShops.add(updatedShop);
      }

      // Create new cart
      final newCart = currentCart.copyWith(shops: updatedShops);
      await _cartService.updateCart(newCart);
      emit(CartLoaded(newCart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCart(
      UpdateCartEvent event, Emitter<CartState> emit) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        final shop = currentCart.getShop(event.shopId);

        if (shop != null && shop.items.containsKey(event.productId)) {
          // Update item quantity
          final updatedItems = Map<String, CartItem>.from(shop.items);
          final item = updatedItems[event.productId]!;
          updatedItems[event.productId] =
              item.copyWith(quantity: event.quantity);

          // Update shop
          final updatedShop = shop.copyWith(items: updatedItems);

          // Update cart shops
          final updatedShops = List<CartShop>.from(currentCart.shops);
          final existingShopIndex =
              updatedShops.indexWhere((shop) => shop.shopId == event.shopId);
          if (existingShopIndex != -1) {
            updatedShops[existingShopIndex] = updatedShop;
          } else {
            updatedShops.add(updatedShop);
          }

          // Create new cart
          final newCart = currentCart.copyWith(shops: updatedShops);
          await _cartService.updateCart(newCart);
          emit(CartLoaded(newCart));
        }
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onDeleteCartProduct(
      DeleteCartProductEvent event, Emitter<CartState> emit) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;
        final shop = currentCart.getShop(event.shopId);

        if (shop != null && shop.items.containsKey(event.productId)) {
          // Remove item from shop
          final updatedItems = Map<String, CartItem>.from(shop.items);
          updatedItems.remove(event.productId);

          // Update shop
          final updatedShop = shop.copyWith(items: updatedItems);

          // Update cart shops
          final updatedShops = List<CartShop>.from(currentCart.shops);
          final existingShopIndex =
              updatedShops.indexWhere((shop) => shop.shopId == event.shopId);
          if (existingShopIndex != -1) {
            if (updatedItems.isEmpty) {
              updatedShops.removeAt(existingShopIndex);
            } else {
              updatedShops[existingShopIndex] = updatedShop;
            }
          }

          // Create new cart
          final newCart = currentCart.copyWith(shops: updatedShops);
          await _cartService.updateCart(newCart);
          emit(CartLoaded(newCart));
        }
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onDeleteCartShop(
      DeleteCartShopEvent event, Emitter<CartState> emit) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cart;

        // Remove shop from cart
        final updatedShops = List<CartShop>.from(currentCart.shops);
        updatedShops.removeWhere((shop) => shop.shopId == event.shopId);

        // Create new cart
        final newCart = currentCart.copyWith(shops: updatedShops);
        await _cartService.updateCart(newCart);
        emit(CartLoaded(newCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
