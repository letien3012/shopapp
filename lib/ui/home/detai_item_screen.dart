import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/item/review_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';
import 'package:intl/intl.dart';

class DetaiItemScreen extends StatefulWidget {
  const DetaiItemScreen({super.key});
  static String routeName = 'Detail_item';

  @override
  State<DetaiItemScreen> createState() => _DetaiItemScreenState();
}

class _DetaiItemScreenState extends State<DetaiItemScreen> {
  // State variables
  final PageController _imageController = PageController();
  final ScrollController _appBarScrollController = ScrollController();
  final GlobalKey _details = GlobalKey();
  int _currentImage = 0;
  bool _isExpanded = false;
  Color _appBarColor = Colors.transparent;
  Color _logoColor = Colors.white;
  Color _searchBarColor = Colors.transparent;
  Color _searchIconColor = Colors.transparent;
  Color _textSearchColor = Colors.transparent;
  int _quantityAddToCart = 1;
  final TextEditingController _quantityController = TextEditingController();
  late Cart cart;
  late Product product;
  late Shop shop;
  String productId = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        /// Gửi sự kiện lấy sản phẩm
        context
            .read<ProductBloc>()
            .add(FetchProductEventByProductId(productId));

        /// Gửi sự kiện lấy giỏ hàng của user
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      }
    });
    // Khởi tạo giá trị mặc định
    cart = Cart(
      id: '',
      userId: '',
      productIdAndQuantity: {},
      listShopId: [],
      productVariantIndexes: {},
      productOptionIndexes: {},
    );
    product = Product(
        id: '',
        name: 'name',
        quantitySold: 0,
        description: '',
        averageRating: 0,
        variants: [],
        shopId: '',
        imageUrl: [],
        shippingMethods: []);
    shop = Shop(
      userId: '',
      name: '',
      addresses: [],
      phoneNumber: '',
      email: '',
      submittedAt: DateTime.now(),
      isClose: false,
      isLocked: false,
      shippingMethods: [],
    );

    _imageController.addListener(() {
      setState(() {
        _currentImage = _imageController.page!.round();
      });
    });
    _appBarScrollController.addListener(onAppBarScroll);
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    _imageController.dispose();
    _appBarScrollController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void onAppBarScroll() {
    if (_appBarScrollController.offset >= 300.0) {
      setState(() {
        _appBarColor = Colors.white;
        _logoColor = Colors.brown;
        _searchBarColor = Colors.grey[200]!;
        _searchIconColor = Colors.grey[500]!;
        _textSearchColor = Colors.grey[500]!;
      });
    } else if (_appBarScrollController.offset >= 250.0) {
      setState(() {
        _appBarColor = Colors.white.withOpacity(0.7);
        _logoColor = Colors.white.withOpacity(0.7);
        _searchBarColor = Colors.white.withOpacity(0.5);
        _searchIconColor = Colors.grey.withOpacity(0.3);
        _textSearchColor = Colors.grey.withOpacity(0.3);
      });
    } else {
      _appBarColor = Colors.transparent;
      _logoColor = Colors.white;
      _searchBarColor = Colors.transparent;
      _searchIconColor = Colors.transparent;
      _textSearchColor = Colors.transparent;
    }
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price.toInt());
  }

  Widget _buildImageSlider(Product product) {
    if (product.imageUrl.isEmpty) {
      return const SizedBox(
        height: 350,
        child: Center(child: Text("Không có hình ảnh")),
      );
    }
    return SizedBox(
      height: 410,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imageController,
            scrollDirection: Axis.horizontal,
            itemCount: product.imageUrl.length,
            itemBuilder: (context, index) {
              return Image.network(
                product.imageUrl[index],
                fit: BoxFit.cover,
              );
            },
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color.fromARGB(221, 31, 30, 30),
                borderRadius: BorderRadius.circular(13),
              ),
              width: 50,
              height: 25,
              child: Center(
                child: Text(
                  '${_currentImage + 1}/${product.imageUrl.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (product.variants[0].label.isNotEmpty)
                    ? 'đ${formatPrice(product.getMinOptionPrice())} - đ${formatPrice(product.getMaxOptionPrice())}'
                    : 'đ${formatPrice(product.variants[0].options[0].price)}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 151, 14, 4),
                ),
              ),
              Text('Đã bán ${product.quantitySold}'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              product.name,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Product product) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ReviewScreen.routeName);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '${product.averageRating}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 143, 28, 20),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 5),
                      const Text(
                        "Đánh giá sản phẩm (10k)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          Container(
            height: 0.2,
            color: Colors.grey,
          ),
          _buildReviewItem(),
          Container(
            height: 0.2,
            color: Colors.grey,
          ),
          _buildReviewItem(),
        ],
      ),
    );
  }

  Widget _buildReviewItem() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              ClipOval(
                child: Container(
                  height: 30,
                  width: 30,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('leminhtien'),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const Text(
                  'Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng',
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (_) => Image.network(
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                      'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo(
      BuildContext context, Shop shop, List<Product> featuredProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  shop.avatarUrl?.isNotEmpty == true
                      ? shop.avatarUrl!
                      : 'https://via.placeholder.com/60',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        shop.addresses[0].city,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 30,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown, width: 1),
                  ),
                  child: const Text(
                    "Xem shop",
                    style: TextStyle(fontSize: 14, color: Colors.brown),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Thêm tiêu đề danh sách sản phẩm nổi bật
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top sản phẩm nổi bật",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Xử lý khi bấm "Xem tất cả"
                },
                child: Row(
                  children: [
                    const Text(
                      "Xem tất cả",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 15, color: Colors.red)
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: featuredProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return _buildProductItem(product);
            },
          ),
        ),
      ],
    );
  }

  /// Widget sản phẩm đơn lẻ
  Widget _buildProductItem(Product product) {
    return Container(
      width: 140, // Chiều rộng của mỗi sản phẩm
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              product.category,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.category}₫",
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      product.averageRating.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Đã bán ${product.id}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Chi tiết sản phẩm",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Xem chi tiết",
                    style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isExpanded
                      ? (_details.currentContext?.findRenderObject()
                              as RenderBox?)
                          ?.size
                          .height
                      : 100,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Text(
                      key: _details,
                      product.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? "Thu gọn" : "Xem thêm ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    return Column(
      children: [
        Container(
          height: 50,
          width: double.infinity,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 1, width: 50, color: Colors.black45),
              const SizedBox(width: 10),
              const Text("Các sản phẩm tương tự",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Container(height: 1, width: 50, color: Colors.black45),
            ],
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
              mainAxisExtent: 280,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(DetaiItemScreen.routeName);
                },
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg',
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        child: const Column(
                          children: [
                            Text(
                              'Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003',
                              style: TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('đ100',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                    maxLines: 1),
                                Text('Đã bán 6.1k',
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSepherated(BuildContext context) {
    return Container(
      height: 10,
      width: double.infinity,
      color: Colors.grey[200],
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      child: AnimatedContainer(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _appBarColor,
          boxShadow: [
            BoxShadow(
              color: _appBarColor != Colors.transparent
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipOval(
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: Icon(Icons.arrow_back, color: _logoColor, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(SearchScreen.routeName);
                },
                child: Container(
                  color: _searchBarColor,
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.search, color: _searchIconColor),
                      const SizedBox(width: 10),
                      Text("Nội dung đề xuất",
                          style:
                              TextStyle(fontSize: 14, color: _textSearchColor)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: ClipOval(
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: Icon(Icons.share_outlined,
                          color: _logoColor, size: 25),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            color: Colors.black12,
                            child: Icon(Icons.shopping_cart_outlined,
                                color: _logoColor, size: 30),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 5,
                          child: Container(
                            height: 18,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red,
                              border:
                                  Border.all(width: 1.5, color: Colors.white),
                            ),
                            child: const Text("99+",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ClipOval(
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: Icon(Icons.more_horiz_outlined,
                          color: _logoColor, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Product product, String userId) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        color: Colors.brown[500],
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                color: const Color.fromARGB(255, 240, 240, 221),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<ChatBloc>().add(StartChatEvent(
                                userId,
                                product.shopId,
                              ));

                          final tempChatRoomId = '$userId-${product.shopId}';
                          Navigator.pushNamed(
                            context,
                            ChatDetailScreen.routeName,
                            arguments: tempChatRoomId,
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.message, color: Colors.brown),
                            Text(
                              "Chat ngay",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 0.8, height: 30, color: Colors.black87),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (product.variants.length == 1 &&
                              product.variants[0].options.length == 1) {
                            context.read<CartBloc>().add(AddCartEvent(
                                product.id,
                                _quantityAddToCart,
                                userId,
                                product.shopId,
                                0,
                                0));
                          } else {
                            showAddToCart(context, product);
                          }
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.cartPlus,
                                color: Colors.brown),
                            Text(
                              "Thêm vào giỏ hàng",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Mua ngay ",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddToCart(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 0.6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        product.imageUrl[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                (product.variants[0].label.isNotEmpty)
                                    ? 'đ${formatPrice(product.getMinOptionPrice())} - '
                                    : 'đ${formatPrice(product.variants[0].options[0].price)}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 151, 14, 4)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                (product.variants[0].label.isNotEmpty)
                                    ? 'đ${formatPrice(product.getMaxOptionPrice())}'
                                    : '',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 151, 14, 4)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Kho: ${product.getTotalOptionStock()}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 0.5,
                    width: double.infinity,
                    color: Colors.grey[300]),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.variants[0].label,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                            product.variants[0].options.length, (index) {
                          return GestureDetector(
                            onTap: () {},
                            child: IntrinsicWidth(
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (product.hasVariantImages)
                                      Image.network(
                                        product.variants[0].options[index]
                                            .imageUrl!,
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.contain,
                                      ),
                                    Text(product
                                        .variants[0].options[index].name),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.variants.length == 2)
              Column(
                children: [
                  Container(
                      height: 0.5,
                      width: double.infinity,
                      color: Colors.grey[400]),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.variants[1].label,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                              product.variants[1].options.length, (index) {
                            return IntrinsicWidth(
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(product
                                        .variants[1].options[index].name),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Column(
              children: [
                Container(
                    height: 0.5,
                    width: double.infinity,
                    color: Colors.grey[400]),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số lượng",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_quantityAddToCart > 1) {
                                    setState(() {
                                      _quantityAddToCart--;
                                      _quantityController.text =
                                          _quantityAddToCart.toString();
                                    });
                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: Colors.grey, width: 1))),
                                  child: Icon(FontAwesomeIcons.minus,
                                      color: Colors.grey[700], size: 13),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                child: TextFormField(
                                  controller: _quantityController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    int? quantity = int.tryParse(value);
                                    if (quantity != null) {
                                      if (quantity <=
                                          product
                                              .variants[0].options[0].stock) {
                                        setState(() {
                                          _quantityAddToCart = quantity;
                                          _quantityController.text =
                                              _quantityAddToCart.toString();
                                        });
                                      } else {
                                        setState(() {
                                          _quantityAddToCart = quantity ~/ 10;
                                          _quantityController.text =
                                              _quantityAddToCart.toString();
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        _quantityController.text =
                                            _quantityAddToCart.toString();
                                      });
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorWidth: 1,
                                  cursorHeight: 13,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_quantityAddToCart <
                                      product.variants[0].options[0].stock) {
                                    setState(() {
                                      _quantityAddToCart++;
                                      _quantityController.text =
                                          _quantityAddToCart.toString();
                                    });
                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: Colors.grey, width: 1))),
                                  child: Icon(FontAwesomeIcons.plus,
                                      color: Colors.grey[700], size: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
                height: 5, width: double.infinity, color: Colors.grey[200]),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  // Thêm logic thêm vào giỏ hàng tại đây nếu cần
                  Navigator.pop(context);
                },
                child: const Text("Thêm vào giỏ hàng",
                    style: TextStyle(fontSize: 16, color: Colors.black38)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    productId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) return _buildLoading();
          if (authState is AuthAuthenticated) {
            return BlocConsumer<ProductBloc, ProductState>(
              listener: (context, productState) {
                if (productState is ProductLoaded) {
                  setState(() {
                    product = productState.product;
                  });
                  context
                      .read<ShopBloc>()
                      .add(FetchShopEventByShopId(productState.product.shopId));
                }
              },
              builder: (context, productState) {
                if (productState is ProductLoading) return _buildLoading();
                if (productState is ProductLoaded) {
                  return BlocConsumer<ShopBloc, ShopState>(
                    listener: (context, shopState) {
                      if (shopState is ShopLoaded) {
                        setState(() {
                          shop = shopState.shop;
                        });
                      }
                    },
                    builder: (context, shopState) {
                      if (shopState is ShopLoading) return _buildLoading();
                      if (shopState is ShopLoaded) {
                        return _buildDetailScreen(
                          context,
                          productState.product,
                          authState.user.uid,
                          shopState.shop,
                        );
                      }
                      if (shopState is ShopError)
                        return _buildError(shopState.message);
                      return _buildInitializing();
                    },
                  );
                }
                if (productState is ProductError)
                  return _buildError(productState.message);
                return _buildInitializing();
              },
            );
          }
          if (authState is AuthError) return _buildError(authState.message);
          return _buildInitializing();
        },
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

  Widget _buildDetailScreen(
      BuildContext context, Product product, String userId, Shop shop) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _appBarScrollController,
          child: Column(
            children: [
              _buildImageSlider(product),
              _buildProductInfo(product),
              _buildSepherated(context),
              _buildReviewsSection(product),
              _buildSepherated(context),
              _buildShopInfo(context, shop, []),
              _buildSepherated(context),
              _buildProductDetails(product),
              _buildSimilarProducts(),
            ],
          ),
        ),
        _buildAppBar(),
        _buildBottomBar(product, userId),
      ],
    );
  }
}
