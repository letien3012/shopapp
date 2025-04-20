import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_event.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/image_feature_service.dart';

// Bloc
class SearchImageBloc extends Bloc<SearchImageEvent, SearchImageState> {
  final ImageFeatureService _imageFeatureService;
  List<Product> _currentProducts = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  SearchImageBloc(this._imageFeatureService) : super(SearchImageInitial()) {
    on<SearchProductsByImage>(_onSearchProductsByImage);
    on<SearchProductRelated>(_onSearchProductRelated);
    // on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
  }
  Future<void> _onSearchProductsByImage(
    SearchProductsByImage event,
    Emitter<SearchImageState> emit,
  ) async {
    try {
      emit(SearchImageLoading());
      final listImageFeature =
          await _imageFeatureService.searchSimilarImages(event.imageUrl);
      emit(SearchImageLoaded(listImageFeature));
    } catch (e) {
      emit(SearchImageError(e.toString()));
    }
  }

  Future<void> _onSearchProductRelated(
    SearchProductRelated event,
    Emitter<SearchImageState> emit,
  ) async {
    try {
      emit(SearchImageLoading());
      final listImageFeature = await _imageFeatureService
          .findRelatedProductsByImageUrl(event.imageUrl);
      emit(SearchImageLoaded(listImageFeature));
    } catch (e) {
      emit(SearchImageError(e.toString()));
    }
  }
  // Future<void> _onLoadMoreSearchResults(
  //   search_event.LoadMoreSearchResults event,
  //   Emitter<search_state.SearchState> emit,
  // ) async {
  //   if (!_hasMore) return;

  //   try {
  //     final products = await _searchService.searchProductsWithPagination(
  //       event.query,
  //       lastDocument: _lastDocument,
  //     );

  //     if (products.isEmpty) {
  //       _hasMore = false;
  //       emit(search_state.SearchLoaded(_currentProducts, hasMore: false));
  //       return;
  //     }

  //     _currentProducts.addAll(products);
  //     _lastDocument =
  //         products.isNotEmpty ? products.last as DocumentSnapshot : null;
  //     emit(search_state.SearchLoaded(_currentProducts));
  //   } catch (e) {
  //     emit(search_state.SearchError(e.toString()));
  //   }
  // }

  // Helper methods
  bool get hasMore => _hasMore;
  DocumentSnapshot? get lastDocument => _lastDocument;
  List<Product> get currentProducts => _currentProducts;
}
