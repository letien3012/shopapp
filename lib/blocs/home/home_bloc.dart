import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/home/home_event.dart';
import 'package:luanvan/blocs/home/home_state.dart';
import 'package:luanvan/services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;

  HomeBloc(this._homeService) : super(HomeInitial()) {
    on<FetchProductWithUserId>(_onFetchProductWithUserId);
    on<FetchProductWithoutUserId>(_onFetchProductsWithoutUserId);
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
