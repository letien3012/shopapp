import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_bloc.dart';
import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_event.dart';
import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class ShopDashboard extends StatefulWidget {
  static String routeName = "shop_dashboard";
  const ShopDashboard({super.key});

  @override
  State<ShopDashboard> createState() => _ShopDashboardState();
}

class _ShopDashboardState extends State<ShopDashboard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  bool _isAscendingPrice = true;

  // Define brown color
  final Color primaryBrown = const Color(0xFF8B4513);

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            _buildShopHeader(),
            _buildFilterTabs(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopLoaded) {
          final shop = state.shop;
          context
              .read<ListproductinshopBloc>()
              .add(FetchListproductinshopEventByShopId(shop.shopId!));

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(shop.backgroundImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm trong Shop',
                                hintStyle: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey[600]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10, top: 5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Shop Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(shop.avatarUrl!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     const Icon(Icons.star,
                              //         color: Colors.amber, size: 16),
                              //     Text(
                              //       ' ${shop.ra}',
                              //       style: const TextStyle(
                              //         fontSize: 13,
                              //         color: Colors.white,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // _buildActionButton('Theo dõi', Icons.add),
                            const SizedBox(height: 5),
                            _buildActionButton('Chat', null, isChat: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionButton(String text, IconData? icon,
      {bool isChat = false}) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: Colors.black)
          else if (isChat)
            SvgPicture.asset(
              IconHelper.chatIcon,
              color: Colors.black,
              width: 18,
              height: 18,
            ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        tabAlignment: TabAlignment.center,
        controller: _tabController,
        isScrollable: true,
        labelColor: primaryBrown,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: primaryBrown,
        tabs: [
          const Tab(text: 'Mới nhất'),
          const Tab(text: 'Bán chạy'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Giá'),
                const SizedBox(width: 4),
                Icon(
                  _isAscendingPrice
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            setState(() {
              _isAscendingPrice = !_isAscendingPrice;
            });
          }
        },
      ),
    );
  }

  List<Product> _getSortedProducts(List<Product> products) {
    switch (_tabController.index) {
      case 0: // Mới nhất
        return List.from(products)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 1: // Bán chạy
        return List.from(products)
          ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
      case 2: // Giá
        return List.from(products)
          ..sort((a, b) => _isAscendingPrice
              ? a.getMinOptionPrice().compareTo(b.getMinOptionPrice())
              : b.getMinOptionPrice().compareTo(a.getMinOptionPrice()));
      default:
        return products;
    }
  }

  Widget _buildProductGrid() {
    return BlocBuilder<ListproductinshopBloc, ListproductinshopState>(
      builder: (context, state) {
        if (state is ListProducInShoptLoaded) {
          var products = state.listProduct;
          final filteredProducts = products.where((product) {
            if (_searchQuery.isEmpty) return true;
            return product.name.toLowerCase().contains(_searchQuery);
          }).toList();

          // Apply sorting
          final sortedProducts = _getSortedProducts(filteredProducts);

          if (sortedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy sản phẩm nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 290,
            ),
            itemCount: sortedProducts.length,
            itemBuilder: (context, index) =>
                _buildProductItem(sortedProducts[index]),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                product.imageUrl[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'đ${formatPrice(product.getMinOptionPrice())}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.averageRating}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã bán ${product.quantitySold}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
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
