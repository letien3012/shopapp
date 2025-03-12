import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/item/review_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

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

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProductBloc>()
          .add(FetchProductEventByProductId('2Fk0wqCDWihRGqnXwH2h'));
    });
    _imageController.addListener(() {
      setState(() {
        _currentImage = _imageController.page!.round();
      });
    });
    _appBarScrollController.addListener(onAppBarScroll);
  }

  @override
  void dispose() {
    _appBarScrollController.dispose();
    super.dispose();
  }

  // Scroll handler
  void onAppBarScroll() {
    if (_appBarScrollController.offset >= 200.0) {
      setState(() {
        _appBarColor = Colors.white;
        _logoColor = Colors.brown;
        _searchBarColor = Colors.grey[200]!;
        _searchIconColor = Colors.grey[500]!;
        _textSearchColor = Colors.grey[500]!;
      });
    } else if (_appBarScrollController.offset >= 100) {
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

  // UI Components
  Widget _buildImageSlider(Product product) {
    return SizedBox(
      height: 350,
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
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'đ100.000.000',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 151, 14, 4),
                ),
              ),
              Text('Đã bán 100k'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm',
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            height: 10,
            width: double.infinity,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ReviewScreen.routeName);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 143, 28, 20),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 5),
                    Text(
                      "Đánh giá sản phẩm (10k)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const Divider(),
        _buildReviewItem(),
        const Divider(),
        _buildReviewItem(),
      ],
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

  Widget _buildProductDetails() {
    return Column(
      children: [
        Container(
          height: 15,
          width: double.infinity,
          color: Colors.grey[200],
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 0.3)),
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
                    ? (_details.currentContext!.findRenderObject() as RenderBox)
                        .size
                        .height
                    : 100,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Text(
                    key: _details,
                    "Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm",
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
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
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
              onTap: () {},
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

  Widget _buildBottomBar() {
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
                        onTap: () {},
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.message, color: Colors.brown),
                            Text(
                              "Chat ngay",
                              style: TextStyle(
                                  color: Colors.brown,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 0.8, height: 30, color: Colors.black87),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showAddToCart(context),
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
                                  fontWeight: FontWeight.w500),
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
                  child: const Text("Mua ngay ",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add to Cart Modal
  void showAddToCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            _buildCartItemInfo(),
            _buildColorOptions(),
            _buildSizeOptions(),
            _buildQuantitySelector(),
            Container(
                height: 10, width: double.infinity, color: Colors.grey[300]),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              child: GestureDetector(
                child: const Text("Thêm vào giỏ hàng",
                    style: TextStyle(fontSize: 16, color: Colors.black38)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemInfo() {
    return Padding(
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
                fit: BoxFit.fill,
                'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg',
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
                      const Icon(FontAwesomeIcons.dongSign,
                          color: Color(0xFFDD0000), size: 15),
                      const Text(
                        "500.000.000",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD0000)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 5),
                      Container(
                          width: 10, height: 2, color: const Color(0xFFDD0000)),
                      const SizedBox(width: 5),
                      IntrinsicWidth(
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.dongSign,
                                color: Color(0xFFDD0000), size: 15),
                            const Text(
                              "500.000.000",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDD0000)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Kho 12',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOptions() {
    return Column(
      children: [
        Container(height: 0.5, width: double.infinity, color: Colors.grey[300]),
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text("Màu sắc", style: TextStyle(fontWeight: FontWeight.w500))
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) {
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
                          Image.network(
                            'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg',
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                          Text("Tên màu ${(index + 100000000) % 15}"),
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
    );
  }

  Widget _buildSizeOptions() {
    return Column(
      children: [
        Container(height: 0.5, width: double.infinity, color: Colors.grey[400]),
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text("Size", style: TextStyle(fontWeight: FontWeight.w500))
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) {
                  return IntrinsicWidth(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[200]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Size ${(index + 100000000) % 15}")],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      children: [
        Container(height: 0.5, width: double.infinity, color: Colors.grey[400]),
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
                        onTap: () {},
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
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(),
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
                        onTap: () {},
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is ProductLoading) return _buildLoading();
        if (productState is ProductLoaded) {
          return _builDetailScreen(context, productState.product);
        } else if (productState is ProductError) {
          return _buildError(productState.message);
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

  Widget _builDetailScreen(BuildContext context, Product product) {
    print(product);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _appBarScrollController,
            child: Column(
              children: [
                _buildImageSlider(product),
                _buildProductInfo(product),
                _buildReviewsSection(),
                _buildProductDetails(),
                _buildSimilarProducts(),
              ],
            ),
          ),
          _buildAppBar(),
          _buildBottomBar(),
        ],
      ),
    );
  }
}
