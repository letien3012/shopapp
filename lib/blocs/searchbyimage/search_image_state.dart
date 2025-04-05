import 'package:luanvan/models/image_feature.dart';

abstract class SearchImageState {}

class SearchImageInitial extends SearchImageState {}

class SearchImageLoading extends SearchImageState {}

class SearchImageLoaded extends SearchImageState {
  final List<ImageFeature> imageFeature;
  final bool hasMore;
  SearchImageLoaded(this.imageFeature, {this.hasMore = true});
}

class SearchImageError extends SearchImageState {
  final String message;
  SearchImageError(this.message);
}
