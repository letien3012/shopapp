import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_bloc.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_event.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_state.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_bloc.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_event.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';

class ProductInCategoryScreen extends StatefulWidget {
  const ProductInCategoryScreen({super.key});
  static const String routeName = "product_in_category_screen";

  @override
  State<ProductInCategoryScreen> createState() =>
      _ProductInCategoryScreenState();
}

class _ProductInCategoryScreenState extends State<ProductInCategoryScreen> {
  // Constants
  static const double _appBarHeight = 80.0;
  static const double _filterBarHeight = 50.0;
  static const double _drawerWidth = 350.0;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // State variables
  String _searchKeyword = '';
  String _categoryLabel = '';
  bool _isRelate = true;
  bool _isNewest = false;
  bool _isBestSelling = false;
  FocusNode _searchFocusNode = FocusNode();
  int _isPrice = 0; // 0: không sắp xếp, 1: tăng dần, 2: giảm dần
  int _selectedRating = -1;
  int _selectedPrice = -1;
  Set<int> _selectedFiltersPlace = {};

  // Thêm biến tạm cho filter
  Set<int> _tempFiltersPlace = {};
  int _tempRating = -1;
  int _tempPrice = -1;
  bool _shouldApplyFilter = false;

  // Thêm biến tạm cho khoảng giá
  double _tempMinPrice = 0;
  double _tempMaxPrice = 0;

  // Thêm biến để kiểm soát lỗi
  String? _minPriceError;
  String? _maxPriceError;

  static const List<String> _rating = [
    "5 sao",
    "Từ 4 sao",
    "Từ 3 sao",
    "Từ 2 sao",
    "Từ 1 sao"
  ];

  static const List<String> _price = [
    "0-100k",
    "100k-200k",
    "200k-300k",
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị cho biến tạm
    _tempFiltersPlace = Set<int>.from(_selectedFiltersPlace);
    _tempRating = _selectedRating;
    _tempPrice = _selectedPrice;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>;
      final categoryId = args['id'];
      final categoryLabel = args['label'];
      if (categoryId != null) {
        context
            .read<ListProductByCategoryBloc>()
            .add(FetchListProductByCategoryEventByCategoryId(categoryId));
        final listProductState =
            context.read<ListProductByCategoryBloc>().state;
        setState(() {
          _categoryLabel = categoryLabel!;
        });

        if (listProductState is ListProductByCategoryLoaded) {
          final shopId = listProductState.listProduct.first.shopId;
          context
              .read<ListShopSearchBloc>()
              .add(FetchListShopSearchEventByShopId([shopId]));
        }
      }
    });
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  // UI Building Methods
  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(_appBarHeight),
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 10),
            _buildSearchField(),
            _buildFilterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: const Alignment(1, 0.6),
      child: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed('/');
          }
        },
        icon: const Icon(Icons.arrow_back, color: Colors.brown, size: 30),
      ),
    );
  }

  Widget _buildSearchField() {
    return Align(
      alignment: const Alignment(1, 0.6),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 46,
        width: 280,
        child: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          decoration: InputDecoration(
            enabledBorder: _buildSearchBorder(),
            focusedBorder: _buildSearchBorder(),
            hintText: 'Tìm trong $_categoryLabel',
            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 15),
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.bottom,
          onChanged: (value) {
            setState(() {
              _searchKeyword = value;
              _shouldApplyFilter = true;
              _isRelate = true; // Enable sorting by relevance when searching
              _isNewest = false;
              _isBestSelling = false;
              _isPrice = 0;
            });
          },
          onTapOutside: (value) {
            setState(() {
              _searchFocusNode.unfocus();
            });
          },
        ),
      ),
    );
  }

  OutlineInputBorder _buildSearchBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.brown),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }

  Widget _buildFilterButton() {
    return Align(
      alignment: const Alignment(1, 0.6),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        child: SizedBox(
          height: 46,
          width: 60,
          child: Stack(
            children: [
              Builder(
                builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.brown,
                      size: 30,
                    )),
              ),
              const Positioned(
                left: 30,
                top: 25,
                child: Text(
                  "Lọc",
                  style: TextStyle(fontSize: 13, color: Colors.brown),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Filter Methods
  void _handleSortingChange(String type) {
    setState(() {
      _isRelate = type == 'relate';
      _isNewest = type == 'newest';
      _isBestSelling = type == 'bestselling';
      if (type != 'price') _isPrice = 0;

      _shouldApplyFilter = true;
    });
  }

  void _handlePriceSort() {
    setState(() {
      _isRelate = false;
      _isNewest = false;
      _isBestSelling = false;
      _isPrice = (_isPrice + 1) % 3;
      if (_isPrice == 0) _isPrice = 1; // Bỏ qua trạng thái không sắp xếp

      _shouldApplyFilter = true;
    });
  }

  String removeDiacritics(String input) {
    const diacritics = {
      'a': 'áàảãạăắằẳẵặâấầẩẫậ',
      'd': 'đ',
      'e': 'éèẻẽẹêếềểễệ',
      'i': 'íìỉĩị',
      'o': 'óòỏõọôốồổỗộơớờởỡợ',
      'u': 'úùủũụưứừửữự',
      'y': 'ýỳỷỹỵ',
    };

    String result = input;
    diacritics.forEach((key, value) {
      for (var i = 0; i < value.length; i++) {
        result = result.replaceAll(value[i], key);
      }
    });
    return result;
  }

  bool isMatch(String keyword, String productName) {
    String normalize(String input) =>
        removeDiacritics(input.toLowerCase().trim());

    final normalizedKeyword = normalize(keyword);
    ;
    final normalizedProductName = normalize(productName);

    final keywordWords = normalizedKeyword.split(RegExp(r'\s+'));

    return keywordWords.every((word) => normalizedProductName.contains(word));
  }

  // Sửa lại phương thức _applyFilters để xử lý sắp xếp theo tên
  List<Product> _applyFilters(List<Product> products) {
    var filteredProducts = products.where((product) {
      final shop = _getShopForProduct(product);
      if (shop == null) return false;
      return true;
    }).toList();

    // Nếu không có filter nào được áp dụng, trả về danh sách đã lọc shop đóng cửa
    if (!_shouldApplyFilter) return filteredProducts;

    // Apply custom price range filter
    if (_tempMinPrice > 0 || _tempMaxPrice > 0) {
      filteredProducts = filteredProducts.where((product) {
        final price = product.getMinOptionPrice();
        if (_tempMinPrice > 0 && _tempMaxPrice > 0) {
          return price >= _tempMinPrice && price <= _tempMaxPrice;
        } else if (_tempMinPrice > 0) {
          return price >= _tempMinPrice;
        } else if (_tempMaxPrice > 0) {
          return price <= _tempMaxPrice;
        }
        return true;
      }).toList();
    }

    // Apply rating filter
    if (_selectedRating != -1) {
      filteredProducts = filteredProducts.where((product) {
        final minRating = 5 - _selectedRating;
        return product.averageRating >= minRating;
      }).toList();
    }

    // Apply sorting
    if (_isNewest) {
      filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_isBestSelling) {
      filteredProducts.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    } else if (_isPrice != 0) {
      filteredProducts.sort((a, b) {
        if (_isPrice == 1) {
          return a
              .getMinOptionPrice()
              .compareTo(b.getMinOptionPrice()); // Tăng dần
        } else {
          return b
              .getMinOptionPrice()
              .compareTo(a.getMinOptionPrice()); // Giảm dần
        }
      });
    } else if (_isRelate || _searchKeyword.isNotEmpty) {
      filteredProducts = filteredProducts.where((element) {
        return isMatch(_searchKeyword, element.name);
      }).toList();
    }

    return filteredProducts;
  }

  Shop? _getShopForProduct(Product product) {
    final state = context.read<ListShopSearchBloc>().state;
    if (state is ListShopSearchLoaded) {
      try {
        return state.shop;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildSortingBar(),
                _buildProductGrid(),
              ],
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: _drawerWidth,
        child: _buildFilterDrawer(),
      ),
    );
  }

  Widget _buildSortingBar() {
    return Container(
      height: _filterBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSortButton(
            "Liên quan",
            _isRelate,
            () => _handleSortingChange('relate'),
          ),
          _buildVerticalDivider(),
          _buildSortButton(
            "Mới nhất",
            _isNewest,
            () => _handleSortingChange('newest'),
          ),
          _buildVerticalDivider(),
          _buildSortButton(
            "Bán chạy",
            _isBestSelling,
            () => _handleSortingChange('bestselling'),
          ),
          _buildVerticalDivider(),
          _buildPriceSortButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton(String text, bool isActive, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.brown : Colors.grey,
        backgroundColor: isActive ? Colors.brown.withOpacity(0.1) : null,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        minimumSize: const Size(80, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _buildPriceSortButton() {
    bool isActive = _isPrice != 0;
    return TextButton(
      onPressed: _handlePriceSort,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.brown : Colors.grey,
        backgroundColor: isActive ? Colors.brown.withOpacity(0.1) : null,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        minimumSize: const Size(80, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Giá"),
          const SizedBox(width: 5),
          _buildPriceSortIcon(),
        ],
      ),
    );
  }

  Widget _buildPriceSortIcon() {
    if (_isPrice == 0) {
      return const Icon(
        Icons.arrow_upward_outlined,
        size: 15,
        color: Colors.grey,
      );
    }
    return Icon(
      _isPrice == 1
          ? Icons.arrow_upward_outlined
          : Icons.arrow_downward_outlined,
      size: 15,
      color: Colors.brown,
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: BlocBuilder<ListProductByCategoryBloc, ListProductByCategoryState>(
        builder: (context, state) {
          if (state is ListProductByCategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ListProductByCategoryLoaded) {
            final filteredProducts = _applyFilters(state.listProduct);
            return Container(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              color: Colors.grey[200],
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy sản phẩm phù hợp'),
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 300,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final shop = _getShopForProduct(product);
                        return _buildProductItem(product, shop!);
                      }),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductItem(Product product, Shop shop) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(DetaiItemScreen.routeName, arguments: product.id),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl[0],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            _buildProductDetails(product, shop),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product, Shop shop) {
    if (product.id == "SSS6gKyKVvhGcqr7Lj7Y") {
      print(product.getMinOptionPrice());
      print(product.optionInfos);
      print(product.variants.length);
    }
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Text(
              product.name,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'đ${formatPrice(product.getMinOptionPrice())}',
                style: TextStyle(fontSize: 16, color: Colors.red),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              Text(
                ' ${product.averageRating.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 10),
              Text(
                'Đã bán ${product.quantitySold}',
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDrawer() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterHeader(),
            // _buildPlaceSellingFilter(),
            _buildPriceRangeFilter(),
            const Divider(),
            _buildRatingFilter(),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.grey[200],
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 10),
      child: const Text(
        "Bộ lọc tìm kiếm",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Khoảng giá (đ)", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          _buildPriceRangeInputs(),
          _buildPriceRangePresets(),
        ],
      ),
    );
  }

  Widget _buildPriceRangeInputs() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey[200],
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceInput("Tối thiểu", true),
          Container(
            alignment: Alignment.center,
            height: 50,
            child: Container(
              width: 30,
              height: 3,
              color: Colors.grey[500],
            ),
          ),
          _buildPriceInput("Tối đa", false),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String hint, bool isMin) {
    return Container(
      height: 50,
      width: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(
          color: (isMin ? _minPriceError : _maxPriceError) != null
              ? Colors.red
              : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 45,
            child: TextField(
              controller: isMin ? _minPriceController : _maxPriceController,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                errorStyle: const TextStyle(height: 0),
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // Reset error message
                  if (isMin) {
                    _minPriceError = null;
                  } else {
                    _maxPriceError = null;
                  }
                  if (value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null) {
                      if (isMin) {
                        _minPriceError = "Giá không hợp lệ";
                      } else {
                        _maxPriceError = "Giá không hợp lệ";
                      }
                    } else {
                      if (isMin) {
                        _tempMinPrice = price;
                        if (_tempMaxPrice > 0 && price > _tempMaxPrice) {
                          _minPriceError =
                              "Giá tối thiểu không thể lớn hơn giá tối đa";
                        }
                      } else {
                        _tempMaxPrice = price;
                        if (_tempMinPrice > 0 && _tempMinPrice > price) {
                          _maxPriceError =
                              "Giá tối đa không thể nhỏ hơn giá tối thiểu";
                        }
                      }
                    }
                    // Khi nhập giá thủ công, bỏ chọn preset price
                    _tempPrice = -1;
                  } else {
                    if (isMin) {
                      _tempMinPrice = 0;
                    } else {
                      _tempMaxPrice = 0;
                    }
                  }
                });
              },
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
          if (isMin && _minPriceError != null)
            Expanded(
              child: Text(
                _minPriceError!,
                style: const TextStyle(color: Colors.red, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!isMin && _maxPriceError != null)
            Expanded(
              child: Text(
                _maxPriceError!,
                style: const TextStyle(color: Colors.red, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRangePresets() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _price.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 7,
          mainAxisExtent: 40,
        ),
        itemBuilder: (context, index) => _buildPricePresetItem(index),
      ),
    );
  }

  Widget _buildPricePresetItem(int index) {
    return GestureDetector(
      onTap: () => _handlePriceFilter(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(
            color: index == _tempPrice ? Colors.brown : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          _price[index],
          style: TextStyle(
            fontSize: 14,
            color: index == _tempPrice ? Colors.brown : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Đánh giá", style: TextStyle(fontSize: 16)),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _rating.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
              mainAxisExtent: 40,
            ),
            itemBuilder: (context, index) => _buildRatingItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(int index) {
    return GestureDetector(
      onTap: () => _handleRatingFilter(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(
            color: index == _tempRating ? Colors.brown : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          _rating[index],
          style: TextStyle(
            fontSize: 14,
            color: index == _tempRating ? Colors.brown : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: _handleApplyFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Text(
            "Áp dụng",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Sửa lại các phương thức xử lý sự kiện filter
  void _handlePlaceFilter(int index) {
    setState(() {
      if (_tempFiltersPlace.contains(index)) {
        _tempFiltersPlace.remove(index);
      } else {
        _tempFiltersPlace.add(index);
      }
    });
  }

  void _handleRatingFilter(int index) {
    setState(() {
      _tempRating = _tempRating == index ? -1 : index;
    });
  }

  void _handlePriceFilter(int index) {
    setState(() {
      _tempPrice = _tempPrice == index ? -1 : index;

      // Clear custom price inputs when selecting preset
      if (_tempPrice != -1) {
        _minPriceController.clear();
        _maxPriceController.clear();
        _minPriceError = null;
        _maxPriceError = null;

        // Set min and max prices based on preset
        switch (index) {
          case 0: // 0-100k
            _tempMinPrice = 0;
            _tempMaxPrice = 100000;
            break;
          case 1: // 100k-200k
            _tempMinPrice = 100000;
            _tempMaxPrice = 200000;
            break;
          case 2: // 200k-300k
            _tempMinPrice = 200000;
            _tempMaxPrice = 300000;
            break;
        }
      } else {
        // Reset prices when deselecting preset
        _tempMinPrice = 0;
        _tempMaxPrice = 0;
      }
    });
  }

  // Thêm phương thức áp dụng filter
  void _handleApplyFilter() {
    // Kiểm tra xem có lỗi không
    if (_minPriceError != null || _maxPriceError != null) {
      return; // Không áp dụng filter nếu có lỗi
    }

    setState(() {
      _selectedFiltersPlace = Set<int>.from(_tempFiltersPlace);
      _selectedRating = _tempRating;
      _selectedPrice = _tempPrice;
      _shouldApplyFilter = true;
    });
    Navigator.pop(context);
  }
}
