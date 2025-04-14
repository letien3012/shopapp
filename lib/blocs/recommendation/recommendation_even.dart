abstract class RecommendationEvent {}

class LoadRecommendations extends RecommendationEvent {
  final String userId;
  LoadRecommendations(this.userId);
}
