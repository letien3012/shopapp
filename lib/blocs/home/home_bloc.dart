import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/home/home_event.dart';
import 'package:luanvan/blocs/home/home_state.dart';
import 'package:luanvan/services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;
  bool _hasMore = true;
  HomeBloc(this._homeService) : super(HomeInitial()) {
    on<InitializeHome>(_onInitializeHome);
    on<LoadMoreProduct>(_onLoadMoreProduct);
    on<FetchProductWithUserId>(_onFetchProductWithUserId);
    on<FetchProductWithoutUserId>(_onFetchProductsWithoutUserId);
  }
  Future<void> _onInitializeHome(InitializeHome event, Emitter emit) async {
    emit(HomeLoading());
    try {
      _homeService.resetPagination();
      final products = await _homeService.getAllProducts(userId: event.userId);
      final hasMore = products.length == 10;
      emit(HomeLoaded(products, hasMore: hasMore));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadMoreProduct(LoadMoreProduct event, Emitter emit) async {
    if (!_hasMore || state is HomeLoading) return;
    try {
      final newProducts = await _homeService.getAllProducts();
      _hasMore = newProducts.length == 10;
      emit(MoreProductLoaded(newProducts, hasMore: _hasMore));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFetchProductsWithoutUserId(
    FetchProductWithoutUserId event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(HomeLoading());
      final products = await _homeService.getAllProducts();
      emit(HomeLoaded(products));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFetchProductWithUserId(
    FetchProductWithUserId event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(HomeLoading());
      final products = await _homeService.getRecommendedProducts(event.userId);
      emit(HomeLoaded(products));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
