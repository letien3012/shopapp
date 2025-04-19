import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/home/home_bloc.dart';
import 'package:luanvan/blocs/home/home_event.dart';
import 'package:luanvan/blocs/home/home_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});
  static String routeName = "demo_screen";
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      }
      context.read<HomeBloc>().add(FetchProductWithoutUserId());
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
          builder: (BuildContext context, AuthState authState) {
        if (authState is AuthLoading) return _buildLoading();
        if (authState is AuthAuthenticated) {
          return BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              if (homeState is HomeLoading) return _buildLoading();
              if (homeState is HomeLoaded) {
                return _buildHomeScreen(context, homeState.products);
              } else if (homeState is HomeError) {
                return _buildError(homeState.message);
              }
              return _buildInitializing();
            },
          );
        } else if (authState is AuthError) {
          return _buildError(authState.message);
        }
        return _buildInitializing();
      }),
    );
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(
        child: Text(
      'Error: $message',
    ));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildHomeScreen(BuildContext context, List<Product> listProduct) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(FetchProductWithoutUserId());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Flash Sale Banner
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.deepOrange,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flash_on, color: Colors.yellow),
                                Text(
                                  'FLASH SALE BÙNG NỔ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTimeBox('13'),
                                Text(':',
                                    style: TextStyle(color: Colors.white)),
                                _buildTimeBox('14'),
                                Text(':',
                                    style: TextStyle(color: Colors.white)),
                                _buildTimeBox('31'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Flash Sale đuy nhất hôm nay',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Text(
                                    'Xem tất cả',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Flash Sale Products
                  Container(
                    height: 140,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildFlashSaleItem(
                            '76%', '5.000', 'assets/images/ao.jpg');
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Mua sắm theo ngành hàng',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.2 -
                                          10,
                                  color: Colors.white,
                                  child: Image.asset(
                                    'assets/images/home_life.png',
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    'Nhà cửa & đời sống',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.2 -
                                          10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/male_fashion.webp',
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    'Thời trang nam',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.2 -
                                          10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/beauty.jpg',
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    'Sắc đẹp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.2 -
                                          10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/female_fashion.png',
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    'Thời trang nữ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context).pushNamed(
                                    //     AllCategoriesScreen.routeName);
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.width *
                                            0.2 -
                                        10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      'assets/images/all_category.png',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Sản phẩm bán chạy 🔥',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 7),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                mainAxisExtent: 280
                                // childAspectRatio: 0.8,
                                ),
                        itemCount: listProduct.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  DetaiItemScreen.routeName,
                                  arguments: listProduct[index].id);
                            },
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    listProduct[index].imageUrl[0],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 42,
                                          child: Text(
                                            listProduct[index].name,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "đ${formatPrice(listProduct[index].getMinOptionPrice())}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 151, 14, 4)),
                                              maxLines: 1,
                                            ),
                                            Text(
                                              'Đã bán ${listProduct[index].quantitySold.toString()}',
                                              style: TextStyle(fontSize: 12),
                                              maxLines: 1,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 90,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.brown,
            ),
            padding:
                const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(SearchScreen.routeName);
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Expanded(
                            child: Text(
                              "Tìm kiếm sản phẩm",
                              style: TextStyle(color: Colors.brown),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt_outlined))
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                  child: SizedBox(
                    height: 40,
                    width: 60,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                              color: Colors.transparent,
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                IconHelper.cartIcon,
                                height: 30,
                                width: 30,
                                color: Colors.white,
                              )),
                        ),
                        (context.read<AuthBloc>().state is AuthAuthenticated)
                            ? BlocSelector<CartBloc, CartState, String>(
                                builder: (BuildContext context, cartItem) {
                                  if (cartItem != '0') {
                                    return Positioned(
                                      right: 15,
                                      top: 5,
                                      child: Container(
                                        height: 20,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1.5, color: Colors.white),
                                        ),
                                        child: Text(
                                          '$cartItem',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                                selector: (state) {
                                  if (state is CartLoaded) {
                                    return state.cart.totalItems.toString();
                                  }
                                  return '';
                                },
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFlashSaleItem(String discount, String price, String image) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Image.asset(image, height: 100, fit: BoxFit.cover),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⚡-$discount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '₫$price',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.red),
                Text(
                  'Choice',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text('Toàn Ngành Hàng'),
            Text(
              'giảm 30% Giảm tối đa 440k',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Đơn tối thiểu ₫100k'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}
