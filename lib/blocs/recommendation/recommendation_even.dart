abstract class RecommendationEvent {}

class LoadRecommendations extends RecommendationEvent {
  final String productId;
  LoadRecommendations(this.productId);
}
