import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/recommendation/recommendation_even.dart';
import 'package:luanvan/blocs/recommendation/recommendation_state.dart';
import 'package:luanvan/services/recommendation_service.dart';

class RecommendationBloc
    extends Bloc<RecommendationEvent, RecommendationState> {
  final RecommendationService recommendationService;

  RecommendationBloc(this.recommendationService)
      : super(RecommendationInitial()) {
    on<LoadRecommendations>((event, emit) async {
      emit(RecommendationLoading());
      try {
        final recommendations =
            await recommendationService.getRecommendations(event.productId);
        emit(RecommendationLoaded(recommendations));
      } catch (e) {
        emit(RecommendationError('Không thể tải gợi ý: $e'));
      }
    });
  }
}
