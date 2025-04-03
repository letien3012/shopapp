import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/banner/banner_event.dart';
import 'package:luanvan/blocs/banner/banner_state.dart';
import 'package:luanvan/services/banner_service.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BannerService _bannerService;

  BannerBloc(this._bannerService) : super(BannerInitial()) {
    on<FetchBannersEvent>(_onFetchBanners);
    on<AddBannerEvent>(_onAddBanner);
    on<UpdateBannerEvent>(_onUpdateBanner);
    on<DeleteBannerEvent>(_onDeleteBanner);
  }

  Future<void> _onFetchBanners(
    FetchBannersEvent event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerLoading());
    try {
      final banners = await _bannerService.getAllBanners();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError(message: e.toString()));
    }
  }

  Future<void> _onAddBanner(
    AddBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      await _bannerService.createBanner(
        event.banner,
      );

      final banners = await _bannerService.getAllBanners();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError(message: e.toString()));
    }
  }

  Future<void> _onUpdateBanner(
    UpdateBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      await _bannerService.updateBanner(
        event.banner,
      );

      final banners = await _bannerService.getAllBanners();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError(message: e.toString()));
    }
  }

  Future<void> _onDeleteBanner(
    DeleteBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    try {
      await _bannerService.deleteBanner(event.id);

      final banners = await _bannerService.getAllBanners();
      emit(BannerLoaded(banners: banners));
    } catch (e) {
      emit(BannerError(message: e.toString()));
    }
  }
}
