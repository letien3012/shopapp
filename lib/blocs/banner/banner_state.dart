import 'package:luanvan/models/banner.dart';

abstract class BannerState {}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerLoaded extends BannerState {
  final List<Banner> banners;

  BannerLoaded({required this.banners});
}

class BannerError extends BannerState {
  final String message;
  BannerError({required this.message});
}
