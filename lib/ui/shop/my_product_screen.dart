import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/add_product_screen.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({super.key});
  static String routeName = "my_product";
  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserInfoModel user;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _scrollToSelectedTab();
      }
    });
  }

  void _scrollToSelectedTab() {
    double tabWidth = 120;
    double position = _tabController.index * tabWidth;

    _scrollController.animateTo(
      position,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as UserInfoModel;
    context.read<ShopBloc>().add(FetchShopEvent(user.id));
    return Scaffold(body: BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoading) {
          return _buildLoading();
        } else if (shopState is ShopLoaded) {
          context
              .read<ProductBloc>()
              .add(FetchProductEventByShopId(shopState.shop.shopId!));
          return BlocBuilder<ProductBloc, ProductState>(
            builder: (context, productState) {
              if (productState is ProductLoading) return _buildLoading();
              if (productState is ListProductLoaded) {
                return _buildShopContent(
                    context, shopState.shop, productState.listProduct);
              } else if (productState is ProductError) {
                return _buildError(productState.message);
              }
              return _buildInitializing();
            },
          );
        } else if (shopState is ShopError) {
          return _buildError(shopState.message);
        }
        return _buildInitializing();
      },
    ));
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildShopContent(
      BuildContext context, Shop shop, List<Product> listProduct) {
    // Lọc danh sách sản phẩm theo từng trạng thái
    final inStockProducts = listProduct
        .where((product) =>
            !product.isDeleted &&
            !product.isHidden &&
            product.getMaxOptionStock() > 0)
        .toList();
    final outOfStockProducts = listProduct
        .where((product) =>
            !product.isDeleted &&
            !product.isHidden &&
            product.getMaxOptionStock() == 0)
        .toList();
    final hiddenProducts = listProduct
        .where((product) => !product.isDeleted && product.isHidden)
        .toList();
    final deletedProducts =
        listProduct.where((product) => product.isDeleted).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height + 90,
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            padding: const EdgeInsets.only(top: 90, bottom: 60),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 40,
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: TabBar(
                      isScrollable: true,
                      padding: EdgeInsets.zero,
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.brown,
                      labelPadding: EdgeInsets.symmetric(horizontal: 16),
                      tabs: [
                        Tab(text: 'Còn hàng (${inStockProducts.length})'),
                        Tab(text: 'Hết hàng (${outOfStockProducts.length})'),
                        Tab(text: 'Đã ẩn (${hiddenProducts.length})'),
                        Tab(text: 'Đã xóa (${deletedProducts.length})'),
                      ],
                    ),
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(inStockProducts), // Còn hàng
                      outOfStockProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm hết hàng")
                          : _buildProductList(outOfStockProducts), // Hết hàng
                      hiddenProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm đã ẩn")
                          : _buildProductList(hiddenProducts), // Đã ẩn
                      deletedProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm đã xóa")
                          : _buildProductList(deletedProducts), // Đã xóa
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // AppBar
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 5),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.brown,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: Text(
                        "Sản phẩm của tôi",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.search, color: Colors.brown, size: 30),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              IconHelper.chatIcon,
                              color: Colors.brown,
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AddProductScreen.routeName, arguments: user);
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Thêm 1 sản phẩm mới",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyTab("Không có sản phẩm");
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Hình ảnh sản phẩm
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl.isNotEmpty
                          ? product.imageUrl[0]
                          : 'https://via.placeholder.com/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                        'https://via.placeholder.com/80',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.variants.isNotEmpty
                              ? "₫${product.getMinOptionPrice()} - ₫${product.getMaxOptionPrice()}"
                              : "₫0",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Kho hàng: ${product.getMaxOptionStock()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Đã bán: ${product.quantitySold}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Lượt xem: 0",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Thích: 0",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Nút hành động
              Row(
                children: [
                  _buildActionButton("Ẩn", Colors.white, Colors.black),
                  const SizedBox(width: 10),
                  _buildActionButton("Sửa", Colors.brown, Colors.white),
                  const SizedBox(width: 10),
                  _buildActionButton("Xóa", Colors.red[800]!, Colors.white),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Nút hành động (Ẩn, Sửa, Xóa)
  Widget _buildActionButton(String label, Color bgColor, Color textColor) {
    return Container(
      height: 35,
      width: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }

  // Tab rỗng (khi không có sản phẩm)
  Widget _buildEmptyTab(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
