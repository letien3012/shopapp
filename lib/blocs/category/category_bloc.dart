import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/category/category_state.dart';
import 'package:luanvan/services/category_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService _categoryService;

  CategoryBloc(this._categoryService) : super(CategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryService.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryService.createCategory(
        event.category,
      );

      final categories = await _categoryService.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryService.updateCategory(
        event.category,
      );

      final categories = await _categoryService.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryService.deleteCategory(event.id);

      final categories = await _categoryService.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
