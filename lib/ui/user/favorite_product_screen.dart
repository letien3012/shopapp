import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_bloc.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_event.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_state.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_bloc.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_event.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_state.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_bloc.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_event.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';

class FavoriteProductScreen extends StatefulWidget {
  const FavoriteProductScreen({super.key});
  static const String routeName = "favorite_product_screen";

  @override
  State<FavoriteProductScreen> createState() => _FavoriteProductScreenState();
}

class _FavoriteProductScreenState extends State<FavoriteProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  FocusNode _searchFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context
            .read<ProductFavoriteBloc>()
            .add(FetchFavoriteProductEvent(authState.user.uid));
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sản phẩm đã thích',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          Container(
            width: 160,
            height: 36,
            margin: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Tìm kiếm...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                ),
                onTapOutside: (value) {
                  _searchFocusNode.unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: BlocBuilder<ProductFavoriteBloc, ProductFavoriteState>(
        builder: (context, state) {
          if (state is ProductFavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductFavoriteLoaded) {
            final filteredProducts = state.listProduct.where((product) {
              return product.name.toLowerCase().contains(_searchQuery);
            }).toList();
            return Container(
              padding: const EdgeInsets.only(
                  top: 15, left: 10, right: 10, bottom: 10),
              color: Colors.grey[200],
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('Không có sản phẩm đã thích'),
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
                        return _buildProductItem(product);
                      }),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
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
            _buildProductDetails(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
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
}
