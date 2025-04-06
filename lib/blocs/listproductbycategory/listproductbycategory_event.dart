abstract class ListProductByCategoryEvent {}

class FetchListProductByCategoryEventByCategoryId
    extends ListProductByCategoryEvent {
  String categoryId;
  FetchListProductByCategoryEventByCategoryId(this.categoryId);
}
