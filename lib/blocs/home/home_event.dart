abstract class HomeEvent {}

class InitializeHome extends HomeEvent {
  String? userId;
  InitializeHome({this.userId});
}

class LoadMoreProduct extends HomeEvent {
  String? userId;
  LoadMoreProduct({this.userId});
}

class FetchProductWithUserId extends HomeEvent {
  final String userId;
  FetchProductWithUserId(this.userId);
}

class FetchProductWithoutUserId extends HomeEvent {}
