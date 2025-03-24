import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routeName = "home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    'https://media.licdn.com/dms/image/v2/C4E12AQGlzsYoKqxHkA/article-cover_image-shrink_600_2000/article-cover_image-shrink_600_2000/0/1634130038864?e=2147483647&v=beta&t=O4Vi4cpdXFDp_Uh8Bcsq1x9tQ9TKGtwrToUFLh9_nyI',
    'https://images.vexels.com/content/194698/preview/shop-online-slider-template-4f2c60.png',
    'https://images.vexels.com/content/194700/preview/buy-online-slider-template-4261dd.png'
  ];

  int bannerCurrentPage = 0;
  final CarouselSliderController _bannercontroller = CarouselSliderController();
  Cart cart = Cart(id: '', userId: '', shops: []);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
          builder: (BuildContext context, AuthState authState) {
        if (authState is AuthLoading) return _buildLoading();
        if (authState is AuthAuthenticated) {
          context
              .read<ListProductBloc>()
              .add(FetchListProductEventByShopId('2Lw9i4fKbZO9x8L4Yieh'));

          return BlocBuilder<ListProductBloc, ListProductState>(
            builder: (context, productState) {
              if (productState is ListProductLoading) return _buildLoading();
              if (productState is ListProductLoaded) {
                return _buildHomeScreen(context, productState.listProduct);
              } else if (productState is ListProductError) {
                return _buildError(productState.message);
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
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: 10),
              color: Colors.grey[200],
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                children: [
                  SizedBox(
                    height: 90,
                  ),
                  StatefulBuilder(builder: (context, setState) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * .25,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: CarouselSlider(
                                  carouselController: _bannercontroller,
                                  items: imgList
                                      .map((item) => Image.network(
                                            item,
                                            fit: BoxFit.cover,
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
                            bottom: MediaQuery.of(context).size.height * .02,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  imgList.length,
                                  (index) {
                                    bool isSelected =
                                        bannerCurrentPage == index;
                                    return GestureDetector(
                                      onTap: () {
                                        _bannercontroller.animateToPage(index);
                                      },
                                      child: AnimatedContainer(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.brown
                                                : Colors.white,
                                            shape: BoxShape.circle),
                                        duration:
                                            const Duration(milliseconds: 300),
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
                  }),
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.grey[300],
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
                                          Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.dongSign,
                                                size: 15,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                "${listProduct[index].getMinOptionPrice()}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red),
                                                maxLines: 1,
                                              ),
                                            ],
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
                      })
                ],
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
                                "tiền đẹp trai",
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
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        },
                        splashColor: Colors.transparent.withOpacity(0.1),
                        highlightColor: Colors.transparent.withOpacity(0.1),
                        child: SizedBox(
                          height: 40,
                          width: 50,
                          child: Stack(
                            children: [
                              Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    IconHelper.cartIcon,
                                    height: 30,
                                    width: 30,
                                    color: Colors.white,
                                  )),
                              cart.totalItems != 0
                                  ? Positioned(
                                      left: 15,
                                      top: 5,
                                      child: Container(
                                        height: 18,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                          border: Border.all(
                                              width: 1.5, color: Colors.white),
                                        ),
                                        child: Text(
                                          "${cart.totalItems}",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    IconHelper.chatIcon,
                    color: Colors.white,
                    height: 30,
                    width: 30,
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
