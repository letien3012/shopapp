import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/category/category_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/category.dart';

class AddProductCategoryScreen extends StatefulWidget {
  const AddProductCategoryScreen({super.key});
  static String routeName = "add_product_category";

  @override
  State<AddProductCategoryScreen> createState() =>
      _AddProductCategoryScreenState();
}

class _AddProductCategoryScreenState extends State<AddProductCategoryScreen> {
  // Danh sách hiển thị sau khi tìm kiếm
  List<Category> categories = [];
  List<Category> suggestedCategories = [];

  // Controller cho ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // Lưu trạng thái danh mục được chọn
  Category? selectedCategory;

  // Stack để lưu lịch sử điều hướng danh mục
  List<Category> navigationStack = [];

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchCategoriesEvent());
    _searchController.addListener(() {
      if (context.read<CategoryBloc>().state is CategoryLoaded) {
        final state = context.read<CategoryBloc>().state as CategoryLoaded;
        filterCategories(_searchController.text, state.categories);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final product = args['product'] as Product?;
      final selectedCategoryId = args['selectedCategory'] as String?;

      if (context.read<CategoryBloc>().state is CategoryLoaded) {
        final state = context.read<CategoryBloc>().state as CategoryLoaded;

        // Đề xuất danh mục nếu có product
        if (product != null) {
          suggestedCategories = _suggestCategories(
              product.name, product.description ?? '', state.categories);
          // Đưa các danh mục được đề xuất lên đầu danh sách
          setState(() {
            categories = [
              ...suggestedCategories,
              ...state.categories.where((c) => !suggestedCategories.contains(c))
            ];
          });
        } else {
          setState(() {
            categories = state.categories;
          });
        }

        // Nếu có category id đã chọn, tìm và thiết lập đường dẫn đến category đó
        if (selectedCategoryId != null) {
          _findAndSetSelectedCategory(selectedCategoryId, state.categories);
        }
      }
    });
  }

  void _findAndSetSelectedCategory(
      String categoryId, List<Category> allCategories) {
    // Tìm category bằng ID trong tất cả categories
    final category = allCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => allCategories.expand((c) => c.children ?? []).firstWhere(
          (c) => c.id == categoryId,
          orElse: () => allCategories.first),
    );

    // Tìm đường dẫn từ gốc đến category
    void findPath(List<Category> cats, List<Category> currentPath) {
      for (var cat in cats) {
        if (cat.id == category.id) {
          // Đã tìm thấy category, cập nhật UI
          setState(() {
            selectedCategory = category;
            navigationStack = List.from(currentPath);
            categories =
                navigationStack.isEmpty ? cats : navigationStack.last.children!;
          });
          return;
        }
        if (cat.children != null) {
          currentPath.add(cat);
          findPath(cat.children!, currentPath);
          if (selectedCategory != null) return; // Đã tìm thấy ở nhánh này
          currentPath.removeLast();
        }
      }
    }

    findPath(allCategories, []);
  }

  // Hàm đề xuất danh mục dựa trên tên và mô tả
  List<Category> _suggestCategories(
      String name, String description, List<Category> allCategories) {
    final Set<Category> suggestions = {};
    final String searchText = '$name $description'.toLowerCase();

    void searchInCategories(List<Category> cats) {
      for (var cat in cats) {
        if (searchText.contains(cat.name.toLowerCase())) {
          suggestions.add(cat);
        }
        if (cat.children != null) {
          searchInCategories(cat.children!);
        }
      }
    }

    searchInCategories(allCategories);
    return suggestions.toList();
  }

  // Hàm lọc danh sách theo từ khóa tìm kiếm
  void filterCategories(String keyword, List<Category> allCategories) {
    setState(() {
      if (keyword.isEmpty) {
        categories = navigationStack.isEmpty
            ? allCategories
            : navigationStack.last.children!;
      } else {
        List<Category> filtered = [];
        void searchInCategories(List<Category> cats) {
          for (var cat in cats) {
            if (cat.name.toLowerCase().contains(keyword.toLowerCase())) {
              filtered.add(cat);
            }
            if (cat.children != null) {
              searchInCategories(cat.children!);
            }
          }
        }

        searchInCategories(allCategories);
        categories = filtered;
      }
    });
  }

  // Hàm cập nhật danh mục hiện tại và stack điều hướng
  void _navigateToCategory(Category category) {
    setState(() {
      if (category.children != null && category.children!.isNotEmpty) {
        navigationStack.add(category);
        categories = category.children!;
      } else {
        selectedCategory = category;
        Navigator.pop(context, category);
      }
    });
  }

  // Hàm quay lại danh mục cha
  void _navigateBack() {
    if (context.read<CategoryBloc>().state is CategoryLoaded) {
      final state = context.read<CategoryBloc>().state as CategoryLoaded;
      setState(() {
        if (navigationStack.isNotEmpty) {
          navigationStack.removeLast();
          if (navigationStack.isEmpty) {
            categories = state.categories;
          } else {
            categories = navigationStack.last.children!;
          }
        }
      });
    }
  }

  // Widget hiển thị breadcrumb navigation
  Widget _buildBreadcrumb() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.home, size: 18),
            label: const Text("Tất cả danh mục"),
            onPressed: () {
              if (context.read<CategoryBloc>().state is CategoryLoaded) {
                final state =
                    context.read<CategoryBloc>().state as CategoryLoaded;
                setState(() {
                  navigationStack.clear();
                  categories = state.categories;
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          ...navigationStack.map((category) {
            return Row(
              children: [
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                TextButton(
                  onPressed: () {
                    setState(() {
                      while (navigationStack.last != category) {
                        navigationStack.removeLast();
                      }
                      categories = category.children!;
                    });
                  },
                  child: Text(
                    category.name,
                    style: const TextStyle(color: Colors.brown),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // Widget hiển thị một danh mục
  Widget _buildCategoryItem(Category category) {
    final bool hasChildren =
        category.children != null && category.children!.isNotEmpty;

    return Column(
      children: [
        ListTile(
          title: Text(
            category.name,
            style: TextStyle(
              color: selectedCategory?.id == category.id
                  ? Colors.brown
                  : Colors.black,
            ),
          ),
          trailing: hasChildren
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null,
          onTap: () => _navigateToCategory(category),
        ),
        const Divider(height: 0.5, thickness: 0.2),
      ],
    );
  }

  // Widget hiển thị danh sách danh mục
  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CategoryError) {
          return Center(child: Text(state.message));
        }

        if (state is CategoryLoaded) {
          if (categories.isEmpty) {
            categories = state.categories;
          }

          return Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                if (navigationStack.isNotEmpty) _buildBreadcrumb(),
                if (categories.isEmpty)
                  const Center(child: Text('Không có danh mục nào'))
                else
                  ...categories.map((cat) => _buildCategoryItem(cat)),
              ],
            ),
          );
        }

        return const Center(child: Text('Đang tải danh mục...'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nội dung chính (danh sách danh mục)
          SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(top: 90, bottom: 60),
              child: _buildCategoryList(),
            ),
          ),
          // AppBar
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Icon trở về
                  GestureDetector(
                    onTap: () {
                      if (navigationStack.isNotEmpty) {
                        _navigateBack();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          if (context.read<CategoryBloc>().state
                              is CategoryLoaded) {
                            final state = context.read<CategoryBloc>().state
                                as CategoryLoaded;
                            filterCategories(value, state.categories);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm ngành hàng...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    if (context.read<CategoryBloc>().state
                                        is CategoryLoaded) {
                                      final state = context
                                          .read<CategoryBloc>()
                                          .state as CategoryLoaded;
                                      filterCategories('', state.categories);
                                    }
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
