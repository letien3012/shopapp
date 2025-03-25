import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';
import 'package:luanvan/services/cart_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc(this._cartService) : super(CartInitial()) {
    on<FetchCartEventUserId>(_onLoadCart);
    on<AddCartEvent>(_onAddCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<UpdateCartEvent>(_onUpdateCart);
    on<DeleteCartProductEvent>(_onDeleteCartProduct);
    on<DeleteCartShopEvent>(_onDeleteCartShop);
    on<ResetCartEvent>(_onResetCart);
  }
  void _onResetCart(ResetCartEvent event, Emitter<CartState> emit) {
    emit(CartInitial());
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

  bool _isSameItem(CartItem item1, CartItem item2) {
    return item1.productId == item2.productId &&
        item1.variantId1 == item2.variantId1 &&
        item1.optionId1 == item2.optionId1 &&
        item1.variantId2 == item2.variantId2 &&
        item1.optionId2 == item2.optionId2;
  }

  Future<void> _onAddCart(AddCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final currentCart = await _cartService.getCartByUserId(event.userId);
      final shop = currentCart!.getShop(event.shopId) ??
          CartShop(
            shopId: event.shopId,
            items: {},
          );

      final newItem = CartItem(
        productId: event.productId,
        quantity: event.quantity,
        variantId1: event.variantId1,
        optionId1: event.optionId1,
        variantId2: event.variantId2,
        optionId2: event.optionId2,
      );

      // Update shop items
      final updatedItems = Map<String, CartItem>.from(shop.items);
      print('Initial items count: ${updatedItems.length}');

      // Hàm tạo key tổng hợp
      String getItemKey(CartItem item) {
        return '${item.productId}_${item.variantId1 ?? ''}_${item.optionId1 ?? ''}_${item.variantId2 ?? ''}_${item.optionId2 ?? ''}';
      }

      // Tìm item hiện có
      CartItem? existingItem;
      String? existingKey;
      for (var entry in updatedItems.entries) {
        if (_isSameItem(entry.value, newItem)) {
          existingItem = entry.value;
          existingKey = entry.key;
          break;
        }
      }

      if (existingItem != null && existingKey != null) {
        // Nếu item đã tồn tại, cập nhật số lượng
        updatedItems[existingKey] = existingItem.copyWith(
          quantity: existingItem.quantity + newItem.quantity,
        );
        print('Updated quantity for key: $existingKey');
      } else {
        // Nếu không tồn tại, thêm newItem với key tổng hợp
        final newKey = getItemKey(newItem);
        updatedItems[newKey] = newItem;
        print('Added new item with key: $newKey');
      }

      print('Updated items count: ${updatedItems.length}');

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
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<CartState> emit) async {
    try {
      final currentCart = await _cartService.getCartByUserId(event.userId);
      final shop = currentCart!.shops.firstWhere(
        (element) => element.shopId == event.shopId,
      );

      if (shop.items.containsKey(event.itemId)) {
        // Update item quantity
        final updatedItems = Map<String, CartItem>.from(shop.items);
        final item = updatedItems[event.itemId]!;
        updatedItems[event.itemId] = item.copyWith(quantity: event.quantity);

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
      }
    } catch (e) {}
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
