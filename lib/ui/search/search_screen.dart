import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:luanvan/blocs/search/search_bloc.dart';
import 'package:luanvan/blocs/search/search_event.dart' as search_event;
import 'package:luanvan/blocs/search/search_event.dart';
import 'package:luanvan/blocs/search/search_state.dart' as search_state;
import 'package:luanvan/blocs/search/search_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static String routeName = "search_screen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GlobalKey _searchHistoryKey = GlobalKey();
  bool _isExpanded = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Tải lịch sử tìm kiếm từ SharedPreferences
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  // Lưu từ khóa tìm kiếm mới
  Future<void> _saveSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    await prefs.setStringList('search_history', _searchHistory);

    setState(() {});
  }

  // Xóa tất cả lịch sử tìm kiếm
  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');

    setState(() {
      _searchHistory = [];
    });
  }

  // Thực hiện tìm kiếm và lưu từ khóa
  void _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      await _saveSearch(keyword);
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
        await _saveSearch(productName);
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
                        hintText: 'Nhập tên sản phẩm',
                        hintStyle:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined),
                        ),
                        suffixIconColor: Colors.brown),
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
              // Lịch sử tìm kiếm và gợi ý tìm kiếm chỉ hiển thị khi không có kết quả tìm kiếm
              if (_searchController.text.isEmpty) ...[
                _searchHistory.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: Text(
                          "Không có lịch sử tìm kiếm",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        key: _searchHistoryKey,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _isExpanded
                            ? _searchHistory.length
                            : _searchHistory.length > 4
                                ? 4
                                : _searchHistory.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              _searchController.text = _searchHistory[index];
                              _performSearch();
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  const Icon(Icons.history, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _searchHistory[index],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.grey, size: 18),
                                    onPressed: () async {
                                      setState(() {
                                        _searchHistory.removeAt(index);
                                      });
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setStringList(
                                          'search_history', _searchHistory);
                                    },
                                  )
                                ],
                              ),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 0.5))),
                            ),
                          );
                        },
                      ),
                if (_searchHistory.isNotEmpty &&
                    (_searchHistory.length > 4 || _isExpanded))
                  GestureDetector(
                    onTap: () {
                      if (_isExpanded) {
                        _clearSearchHistory();
                      } else {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey, width: 0.5))),
                      child: Text(
                        _isExpanded ? "Xóa tất cả lịch sử" : "Xem thêm",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                Container(
                  height: 10,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                // Gợi ý tìm kiếm
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Gợi ý tìm kiếm",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: 230),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(DetaiItemScreen.routeName);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                        width: double.infinity,
                                        height: 170,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      child: const Column(
                                        children: [
                                          Text(
                                            'Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
