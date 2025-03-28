abstract class ListUserOrderEvent {}

class FetchListUserOrderEventByUserId extends ListUserOrderEvent {
  final List<String> userIds;
  FetchListUserOrderEventByUserId(this.userIds);
}

class ResetListUserOrderEvent extends ListUserOrderEvent {}
