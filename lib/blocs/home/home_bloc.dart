import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/home/home_event.dart';
import 'package:luanvan/blocs/home/home_state.dart';
import 'package:luanvan/services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;

  HomeBloc(this._homeService) : super(HomeInitial()) {
    on<FetchAllProducts>(_onFetchAllProducts);
  }

  Future<void> _onFetchAllProducts(
    FetchAllProducts event,
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
}
