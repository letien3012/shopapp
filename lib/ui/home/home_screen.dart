import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/banner/banner_bloc.dart';
import 'package:luanvan/blocs/banner/banner_event.dart';
import 'package:luanvan/blocs/banner/banner_state.dart';
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
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routeName = "home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bannerCurrentPage = 0;
  final CarouselSliderController _bannercontroller = CarouselSliderController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Product> _products = [];
  bool _hasMore = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
      context.read<BannerBloc>().add(FetchBannersEvent());
    });
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          _loadMore();
        }
      }
    });
  }

  void _loadMore() async {
    if (!_hasMore) return;
    setState(() => _isLoading = true);
    context.read<HomeBloc>().add(LoadMoreProduct());
    await context
        .read<HomeBloc>()
        .stream
        .firstWhere((state) => state is MoreProductLoaded);
    setState(() {
      _products.addAll(
          (context.read<HomeBloc>().state as MoreProductLoaded).newProduct);
      _isLoading = false;
      _hasMore = (context.read<HomeBloc>().state as MoreProductLoaded).hasMore;
    });
  }

  void _loadProduct() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      context.read<HomeBloc>().add(InitializeHome(userId: authState.user.uid));
      await context
          .read<HomeBloc>()
          .stream
          .firstWhere((state) => state is HomeLoaded);
      setState(() {
        _products = (context.read<HomeBloc>().state as HomeLoaded).products;
      });
    } else {
      context.read<HomeBloc>().add(InitializeHome());
      await context
          .read<HomeBloc>()
          .stream
          .firstWhere((state) => state is HomeLoaded);
      setState(() {
        _products = (context.read<HomeBloc>().state as HomeLoaded).products;
      });
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        if (homeState is HomeLoading) return _buildLoading();
        if (homeState is HomeLoaded || homeState is MoreProductLoaded) {
          return _buildHomeScreen(context, _products);
        } else if (homeState is HomeError) {
          return _buildError(homeState.message);
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

  Widget _buildHomeScreen(BuildContext context, List<Product> listProduct) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _loadProduct();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(bottom: 10),
                color: Colors.grey[200],
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    SizedBox(
                      height: 90,
                    ),
                    BlocBuilder<BannerBloc, BannerState>(
                      builder: (context, bannerState) {
                        if (bannerState is BannerLoading)
                          return _buildLoading();
                        if (bannerState is BannerLoaded) {
                          final banners = bannerState.banners;
                          banners.sort(
                              (a, b) => a.createdAt.compareTo(b.createdAt));
                          if (banners.isEmpty) return Container();
                          final imgList = banners
                              .where((banner) => !banner.isHidden)
                              .map((banner) => banner.imageUrl)
                              .toList();

                          return SizedBox(
                            height: MediaQuery.of(context).size.height * .2,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                    child: CarouselSlider(
                                        carouselController: _bannercontroller,
                                        items: imgList
                                            .map((item) => Image.network(
                                                  item,
                                                  fit: BoxFit.fitWidth,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .25,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                ))
                                            .toList(),
                                        options: CarouselOptions(
                                          autoPlay: true,
                                          enlargeCenterPage: true,
                                          enableInfiniteScroll: true,
                                          viewportFraction: 1,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              bannerCurrentPage = index;
                                            });
                                          },
                                        ))),
                                Positioned(
                                  bottom:
                                      MediaQuery.of(context).size.height * .02,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        imgList.length,
                                        (index) {
                                          bool isSelected =
                                              bannerCurrentPage == index;
                                          return GestureDetector(
                                            onTap: () {
                                              _bannercontroller
                                                  .animateToPage(index);
                                            },
                                            child: AnimatedContainer(
                                              width: 8,
                                              height: 8,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.brown
                                                      : Colors.white,
                                                  shape: BoxShape.circle),
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.ease,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                            !(context.read<AuthBloc>().state
                                    is AuthAuthenticated)
                                ? 'Sản phẩm bán chạy 🔥'
                                : 'Sản phẩm phù hợp nhất',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
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
                      },
                    ),
                    if (_isLoading)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 40,
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: Text('Đang tải...'),
                        ),
                      )
                    else if (!_hasMore)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 40,
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(child: Text('Đã hết sản phẩm')),
                      )
                    else
                      SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),

          //Appbar
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.brown,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 0),
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
                          Navigator.of(context)
                              .pushNamed(SearchScreen.routeName);
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
                            // IconButton(
                            //     onPressed: () {
                            //       Navigator.of(context)
                            //           .pushNamed(SearchScreen.routeName);
                            //     },
                            //     icon: const Icon(Icons.camera_alt_outlined))
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
                      if (context.read<AuthBloc>().state is AuthAuthenticated) {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      } else {
                        Navigator.of(context).pushNamed(SigninScreen.routeName);
                      }
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
                                                width: 1.5,
                                                color: Colors.white),
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
      ),
    );
  }
}
