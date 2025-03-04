import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  static String routeName = "review_screen";
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // bool _isExpanded = false;
  // final GlobalKey _details = GlobalKey();
  // Map<String, List<String>> _reviews = {};
  int soLuongAnh = 5;
  @override
  void initState() {
    super.initState();
  }

  void showAddToCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 0.6)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                          width: 110,
                          height: 110,
                          fit: BoxFit.fill,
                          'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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
                            const Icon(
                              FontAwesomeIcons.dongSign,
                              color: Color(0xFFDD0000),
                              size: 15,
                            ),
                            const Text(
                              "500.000.000",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDD0000)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 10,
                              height: 2,
                              color: const Color(0xFFDD0000),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const IntrinsicWidth(
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.dongSign,
                                    color: Color(0xFFDD0000),
                                    size: 15,
                                  ),
                                  Text(
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
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Kho 12',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: Colors.grey[300],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Màu sắc",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg',
                                width: 35,
                                height: 35,
                                fit: BoxFit.contain,
                              ),
                              Text("Tên màu ${(index + 100000000) % 15}")
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: Colors.grey[400],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Size",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Size ${(index + 100000000) % 15}")
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: Colors.grey[400],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Số lượng",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
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
                              child: Icon(
                                FontAwesomeIcons.minus,
                                color: Colors.grey[700],
                                size: 13,
                              ),
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
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.zero),
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                cursorWidth: 1,
                                cursorHeight: 13,
                                style: const TextStyle(fontSize: 13),
                              ),
                            )),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Colors.grey, width: 1))),
                              child: Icon(
                                FontAwesomeIcons.plus,
                                color: Colors.grey[700],
                                size: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 10,
              width: double.infinity,
              color: Colors.grey[300],
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              child: GestureDetector(
                child: const Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(fontSize: 16, color: Colors.black38),
                ),
              ),
            )
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.only(top: 130, bottom: 70),
            child: Column(
              children: [
                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 15, right: 15),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: Colors.grey))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                height: 30,
                                width: 30,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'leminhtien',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.thumbsUp,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Thích(7)")
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.more_horiz_rounded),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Phân loại: Trắng XL",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                                'Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng'),
                            soLuongAnh == 3
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: StaggeredGrid.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      children: [
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              'https://pos.nvncdn.com/778773-105877/ps/20221013_n6HKsuzizp6K2vDgrJLI4qA8.jpg'),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 1,
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              'https://pos.nvncdn.com/778773-105877/ps/20221013_n6HKsuzizp6K2vDgrJLI4qA8.jpg'),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 1,
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              'https://pos.nvncdn.com/778773-105877/ps/20221013_n6HKsuzizp6K2vDgrJLI4qA8.jpg'),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: soLuongAnh > 4 ? 4 : soLuongAnh,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5),
                                    itemBuilder: (context, index) => Image.network(
                                        fit: BoxFit.cover,
                                        'https://pos.nvncdn.com/778773-105877/ps/20221013_n6HKsuzizp6K2vDgrJLI4qA8.jpg'),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // AppBar
          Positioned(
              child: Column(
            children: [
              Container(
                height: 80,
                padding: const EdgeInsets.only(bottom: 10),
                alignment: Alignment.bottomCenter,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Icon trở về
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                        child: Text(
                      "Đánh giá",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Giỏ hàng
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(CartScreen.routeName);
                          },
                          child: Container(
                            width: 50,
                            child: Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.brown,
                                  size: 30,
                                ),
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  child: Container(
                                    height: 18,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.red,
                                        border: Border.all(
                                            width: 1.5, color: Colors.white)),
                                    child: const Text(
                                      "99+",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //Thêm cài đặt
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            BoxIcons.bx_chat,
                            color: Colors.brown,
                            size: 30,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: 40,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Colors.black))),
                          child: const Text(
                            "Đánh giá sản phẩm",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Colors.black))),
                          child: const Text(
                            "Đánh giá shop",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),

          // Bottom AppBar
          Positioned(
            bottom: 0,
            child: Container(
              height: 55,
              width: MediaQuery.of(context).size.width,
              color: Colors.brown,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 5),
                      color: Colors.green[700],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Chat với người bán
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.message,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Chat ngay",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 0.8,
                            height: 30,
                            color: Colors.black87,
                          ),

                          // Thêm vào giỏ hàng
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showAddToCart(context);
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.cartPlus,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Thêm vào giỏ hàng",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Mua ngay
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
                  ))
                ],
              ),
            ),
          ),
          // Positioned(
          //   top: 35,
          //   right: 58,
          //   child: Container(
          //     height: 18,
          //     width: 30,
          //     alignment: Alignment.center,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(8),
          //         color: Colors.red,
          //         border: Border.all(width: 1.5, color: Colors.white)),
          //     child: const Text(
          //       "99+",
          //       style: TextStyle(fontSize: 10, color: Colors.white),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
