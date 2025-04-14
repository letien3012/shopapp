abstract class HomeEvent {}

class FetchProductWithUserId extends HomeEvent {
  final String userId;
  FetchProductWithUserId(this.userId);
}

class FetchProductWithoutUserId extends HomeEvent {}
