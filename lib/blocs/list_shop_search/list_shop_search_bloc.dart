import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_event.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/shop_service.dart';

class ListShopSearchBloc
    extends Bloc<ListShopSearchEvent, ListShopSearchState> {
  final ShopService _shopService;

  ListShopSearchBloc(this._shopService) : super(ListShopSearchInitial()) {
    on<FetchListShopSearchEventByShopId>(_onFetchListShopSearchByShopId);
    on<ResetListShopSearchEvent>(
        (event, emit) => emit(ListShopSearchInitial()));
  }

  Future<void> _onFetchListShopSearchByShopId(
      FetchListShopSearchEventByShopId event,
      Emitter<ListShopSearchState> emit) async {
    emit(ListShopSearchLoading());
    try {
      final List<Shop> shops =
          await _shopService.fetchListShopByShopId(event.shopIds);
      emit(ListShopSearchLoaded(shops));
    } catch (e) {
      emit(ListShopSearchError(e.toString()));
    }
  }
}
