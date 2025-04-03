import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/details_product_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_product_screen.dart';
import 'package:intl/intl.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({super.key});
  static String routeName = "my_product";

  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Shop shop;
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _numberFormat =
      NumberFormat("#,###", "vi_VN"); // Định dạng số với dấu chấm
  String shopId = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopId = ModalRoute.of(context)!.settings.arguments as String;
      context
          .read<ListProductBloc>()
          .add(FetchListProductEventByShopId(shopId));
    });

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

  void _hideProduct(Product product) {
    context.read<ProductBloc>().add(UpdateProductEvent(product));
  }

  void _editProduct(Product product) {
    Navigator.of(context).pushNamed(
      EditProductScreen.routeName,
      arguments: {
        'product': product,
      },
    );
  }

  void _deleteProduct(String productId, String shopId) {
    context.read<ProductBloc>().add(DeleteProductByIdEvent(productId, shopId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductLoaded) {
            final shopId = ModalRoute.of(context)!.settings.arguments as String;
            context
                .read<ListProductBloc>()
                .add(FetchListProductEventByShopId(shopId));
          }
        },
        child: BlocBuilder<ListProductBloc, ListProductState>(
          builder: (context, productState) {
            if (productState is ListProductLoading) {
              return _buildLoading();
            } else if (productState is ListProductLoaded) {
              return _buildShopContent(context, productState.listProduct);
            } else if (productState is ListProductError) {
              return _buildError(productState.message);
            }
            return _buildInitializing();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildShopContent(BuildContext context, List<Product> listProduct) {
    final inStockProducts = listProduct
        .where((product) =>
            !product.isViolated &&
            !product.isHidden &&
            product.getMaxOptionStock() > 0)
        .toList();
    final outOfStockProducts = listProduct
        .where((product) =>
            !product.isViolated &&
            !product.isHidden &&
            product.getMaxOptionStock() == 0)
        .toList();
    final hiddenProducts = listProduct
        .where((product) => !product.isViolated && product.isHidden)
        .toList();
    final violatedProducts =
        listProduct.where((product) => product.isViolated).toList();

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
                        Tab(text: 'Vi phạm (${violatedProducts.length})'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(inStockProducts),
                      outOfStockProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm hết hàng")
                          : _buildProductList(outOfStockProducts),
                      hiddenProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm đã ẩn")
                          : _buildProductList(hiddenProducts),
                      violatedProducts.isEmpty
                          ? _buildEmptyTab("Không có sản phẩm vi phạm")
                          : _buildProductList(violatedProducts),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                Navigator.of(context).pushNamed(
                  AddProductScreen.routeName,
                  arguments: shopId,
                );
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
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, DetailsProductShopScreen.routeName,
                      arguments: product.id);
                },
                child: Row(
                  children: [
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
                            (product.variants.isNotEmpty)
                                ? (product.getMinOptionPrice() !=
                                        product.getMaxOptionPrice())
                                    ? "đ${_numberFormat.format(product.getMinOptionPrice())} - đ${_numberFormat.format(product.getMaxOptionPrice())}"
                                    : "đ${_numberFormat.format(product.getMinOptionPrice())}"
                                : "đ${_numberFormat.format(product.price ?? 0)}",
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
              Row(
                children: [
                  _buildActionButton(
                      product.isHidden ? "Hiện" : "Ẩn",
                      Colors.white,
                      Colors.black,
                      product.isHidden
                          ? () =>
                              _hideProduct(product.copyWith(isHidden: false))
                          : () =>
                              _hideProduct(product.copyWith(isHidden: true))),
                  const SizedBox(width: 10),
                  _buildActionButton("Sửa", Colors.brown, Colors.white,
                      () => _editProduct(product)),
                  const SizedBox(width: 10),
                  _buildActionButton("Xóa", Colors.red[800]!, Colors.white,
                      () => _deleteProduct(product.id, product.shopId)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      child: InkWell(
        splashColor: bgColor.withOpacity(0.2),
        highlightColor: bgColor.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
