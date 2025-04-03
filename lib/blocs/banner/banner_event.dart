import 'package:luanvan/models/banner.dart';

abstract class BannerEvent {}

class FetchBannersEvent extends BannerEvent {}

class AddBannerEvent extends BannerEvent {
  final Banner banner;

  AddBannerEvent({
    required this.banner,
  });
}

class UpdateBannerEvent extends BannerEvent {
  final Banner banner;

  UpdateBannerEvent({
    required this.banner,
  });
}

class DeleteBannerEvent extends BannerEvent {
  final String id;
  DeleteBannerEvent({required this.id});
}
