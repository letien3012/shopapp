import 'package:luanvan/models/category.dart';

abstract class CategoryEvent {}

class FetchCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final Category category;

  AddCategoryEvent({
    required this.category,
  });
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  UpdateCategoryEvent({
    required this.category,
  });
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  DeleteCategoryEvent({required this.id});
}
