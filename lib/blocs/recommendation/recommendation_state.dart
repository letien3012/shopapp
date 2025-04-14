import 'package:luanvan/models/product.dart';

abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<Product> recommendedProducts;

  RecommendationLoaded(this.recommendedProducts);
}

class RecommendationError extends RecommendationState {
  final String message;

  RecommendationError(this.message);
}
