import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/shop_service.dart';

class ListShopBloc extends Bloc<ListShopEvent, ListShopState> {
  final ShopService _shopService;

  ListShopBloc(this._shopService) : super(ListShopInitial()) {
    on<FetchListShopEventByShopId>(_onFetchListShopByShopId);

    on<ResetListShopEvent>((event, emit) => emit(ListShopInitial()));
  }

  Future<void> _onFetchListShopByShopId(
      FetchListShopEventByShopId event, Emitter<ListShopState> emit) async {
    emit(ListShopLoading());
    try {
      final List<Shop> shops =
          await _shopService.fetchListShopByShopId(event.shopIds);
      emit(ListShopLoaded(shops));
    } catch (e) {
      emit(ListShopError(e.toString()));
    }
  }
}
