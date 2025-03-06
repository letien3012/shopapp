import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 90,
                ),
                SizedBox(
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .25,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                bool isSelected = bannerCurrentPage == index;
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
                                    duration: const Duration(milliseconds: 300),
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
                ),
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
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(DetaiItemScreen.routeName);
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
                                  'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                              Container(
                                padding: const EdgeInsets.all(6),
                                child: const Column(
                                  children: [
                                    const Text(
                                      'Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003 Áo Polo trơn bo kẻ FSTP003',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'đ100',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.red),
                                          maxLines: 1,
                                        ),
                                        Text(
                                          'Đã bán 6.1k',
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
                                    border: Border.all(
                                        width: 1.5, color: Colors.white),
                                  ),
                                  child: const Text(
                                    "99+",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              )
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
