import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:luanvan/blocs/search/search_bloc.dart';
import 'package:luanvan/blocs/search/search_event.dart';
import 'package:luanvan/blocs/search/search_state.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_bloc.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_event.dart';
import 'package:luanvan/ui/search/search_image_result.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';

import 'package:image_picker/image_picker.dart';

class SearchInCategoryScreen extends StatefulWidget {
  const SearchInCategoryScreen({super.key});
  static String routeName = "search_in_category_screen";

  @override
  State<SearchInCategoryScreen> createState() => _SearchInCategoryScreenState();
}

class _SearchInCategoryScreenState extends State<SearchInCategoryScreen> {
  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _categoryLabel = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)?.settings.arguments as String;
      if (args != null) {
        _categoryLabel = args;
      }
    });
  }

  void _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          SearchResultScreen.routeName,
          arguments: keyword,
        );
      }
    }
  }

  // Xử lý khi người dùng nhập text
  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isNotEmpty) {
        context.read<SearchBloc>().add(SuggestSearch(query));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildProductTile(String productName) {
    return ListTile(
      leading: const Icon(Icons.search, color: Colors.grey),
      title: Text(
        productName,
        style: const TextStyle(fontSize: 14),
      ),
      onTap: () async {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            SearchResultScreen.routeName,
            arguments: productName,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Align(
                alignment: const Alignment(1, 0.6),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.brown,
                      size: 30,
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              Align(
                alignment: const Alignment(1, 0.6),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 46,
                  width: 290,
                  child: TextField(
                    controller: _searchController,
                    maxLines: 1,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      hintText: 'Tìm trong $_categoryLabel',
                      hintStyle:
                          const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.bottom,
                    autofocus: true,
                    onSubmitted: (value) {
                      _performSearch();
                    },
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(1, 0.6),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  child: Container(
                    height: 46,
                    color: Colors.brown,
                    child: IconButton(
                        onPressed: _performSearch,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            children: [
              // Kết quả tìm kiếm gợi ý
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is SearchSuggestLoaded &&
                      state.suggestions.isNotEmpty) {
                    return Container(
                      color: Colors.white,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (state.suggestions.length > 10)
                            ? 10
                            : state.suggestions.length,
                        itemBuilder: (context, index) {
                          return _buildProductTile(state.suggestions[index]);
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
