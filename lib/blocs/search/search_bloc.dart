import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/blocs/search/search_event.dart';
import 'package:luanvan/blocs/search/search_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/search_service.dart';
import 'package:luanvan/blocs/search/search_event.dart' as search_event;
import 'package:luanvan/blocs/search/search_state.dart' as search_state;

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService _searchService;
  List<Product> _currentProducts = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  SearchBloc(this._searchService) : super(SearchInitial()) {
    on<SuggestSearch>(_onSuggestSearch);
    on<SearchProducts>(_onSearchProducts);
    on<SearchProductsByShop>(_onSearchProductsByShop);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
  }
  Future<void> _onSuggestSearch(
    SuggestSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(SearchLoading());
      final listSuggest =
          await _searchService.searchNameProducts(event.keyword);
      emit(SearchSuggestLoaded(listSuggest));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    search_event.SearchProducts event,
    Emitter<search_state.SearchState> emit,
  ) async {
    try {
      emit(search_state.SearchLoading());
      _currentProducts = [];
      _lastDocument = null;
      _hasMore = true;

      final products = await _searchService.searchProducts(event.query);
      _currentProducts = products;
      emit(search_state.SearchLoaded(products));
    } catch (e) {
      emit(search_state.SearchError(e.toString()));
    }
  }

  Future<void> _onSearchProductsByShop(
    search_event.SearchProductsByShop event,
    Emitter<search_state.SearchState> emit,
  ) async {
    try {
      emit(search_state.SearchLoading());
      _currentProducts = [];
      _lastDocument = null;
      _hasMore = true;
      final products =
          await _searchService.searchProductsByShop(event.query, event.shopId);
      _currentProducts = products;
      emit(search_state.SearchLoaded(products));
    } catch (e) {
      emit(search_state.SearchError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSearchResults(
    search_event.LoadMoreSearchResults event,
    Emitter<search_state.SearchState> emit,
  ) async {
    if (!_hasMore) return;

    try {
      final products = await _searchService.searchProductsWithPagination(
        event.query,
        lastDocument: _lastDocument,
      );

      if (products.isEmpty) {
        _hasMore = false;
        emit(search_state.SearchLoaded(_currentProducts, hasMore: false));
        return;
      }

      _currentProducts.addAll(products);
      _lastDocument =
          products.isNotEmpty ? products.last as DocumentSnapshot : null;
      emit(search_state.SearchLoaded(_currentProducts));
    } catch (e) {
      emit(search_state.SearchError(e.toString()));
    }
  }

  // Helper methods
  bool get hasMore => _hasMore;
  DocumentSnapshot? get lastDocument => _lastDocument;
  List<Product> get currentProducts => _currentProducts;
}
