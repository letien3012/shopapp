import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/shop_service.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopService _shopService;

  ShopBloc(this._shopService) : super(ShopInitial()) {
    on<FetchShopEvent>(_onFetchShop);
    on<FetchShopEventByShopId>(_onFetchShopByShopId);
    on<UpdateShopEvent>(_onUpdateShop);
    on<HideShopEvent>(_onHideShop);
    on<GetShopEvent>(_onGetShop);
    on<ResetShopEvent>((event, emit) => emit(ShopInitial()));
  }
  Future<void> _onFetchShop(
      FetchShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final Shop shop = await _shopService.fetchShop(event.userId);
      emit(ShopLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onFetchShopByShopId(
      FetchShopEventByShopId event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final Shop shop = await _shopService.fetchShopByShopId(event.shopId);
      emit(ShopLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onUpdateShop(
      UpdateShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      await _shopService.updateShop(event.shop);
      final shop = await _shopService.fetchShopByShopId(event.shop.shopId!);
      emit(ShopLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onGetShop(GetShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final Shop shop = await _shopService.getShop();
      emit(ShopLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onHideShop(HideShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      // await _userService.registrationSeller(event.shop);
      // final UserInfoModel user =
      //     await _userService.fetchUserInfo(event.shop.userId);
      // emit(ShopLoaded(user));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }
}
