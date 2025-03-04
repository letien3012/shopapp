import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static String routeName = "cart_screen";
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Map<String, Map<dynamic, List<dynamic>>> cart = {
  //   "Đây là shop 1": {"aaa": [
  //     "Tến sản phẩm của shop 1 Tến sản phẩm của shop 1",
  //     "price1"
  //   ],
  //   }
  //   "Đây là shop 2": [
  //     "Tến sản phẩm của shop 2 Tến sản phẩm của shop 2",
  //     "price2"
  //   ],
  // };
  List<bool> checkedShop = [];
  Map<String, List<bool>> checkedProduct = {};
  bool checkAllProduct = false;
  bool editProduct = false;

  double _dragExtent = 0;
  final double _maxSwipe = 80;
  @override
  void initState() {
    super.initState();
    checkedShop = List.generate(3, (item) => false);

    for (int i = 0; i <= checkedShop.length; i++) {
      checkedProduct['Shop$i'] = List.filled(2, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 90, bottom: 60),
              child: Column(
                children: [
                  // Danh sách các shop trong giỏ hàng
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        String shopName = "Shop$index";
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10, bottom: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    fillColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Colors.brown;
                                      }
                                      return Colors.transparent;
                                    }),
                                    value: checkedShop[index],
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        checkedShop[index] = newValue ?? false;
                                        checkedProduct["Shop$index"] =
                                            List.filled(2, newValue ?? false);
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Đây là tên shop Đây là tên  tên shop Đây là tên",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_right_outlined,
                                          color: Colors.grey[500],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Sửa",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  )
                                ],
                              ),

                              // Hiển thị danh sách sản phẩm của 1 shop trong giỏ hàng
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: 2,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) => Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          alignment: Alignment.center,
                                          height: 130,
                                          width: _dragExtent,
                                          color: Colors.brown,
                                          child: const Text(
                                            "Xóa",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          if (details.primaryDelta! < 0) {
                                            _dragExtent = max(
                                                0,
                                                min(
                                                    _dragExtent -
                                                        details.primaryDelta!,
                                                    _maxSwipe));
                                          }
                                          if (details.primaryDelta! > 0) {
                                            _dragExtent = (_dragExtent -
                                                    details.primaryDelta!)
                                                .clamp(0, _maxSwipe);
                                          }
                                        });
                                      },
                                      onHorizontalDragEnd: (details) {
                                        setState(() {
                                          _dragExtent =
                                              (_dragExtent > _maxSwipe / 2)
                                                  ? _maxSwipe
                                                  : 0;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        transform: Matrix4.translationValues(
                                            -_dragExtent, 0, 0),
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.linear,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              children: [
                                                Checkbox(
                                                  fillColor: WidgetStateProperty
                                                      .resolveWith<Color>(
                                                          (states) {
                                                    if (states.contains(
                                                        WidgetState.selected)) {
                                                      return Colors.brown;
                                                    }
                                                    return Colors.transparent;
                                                  }),
                                                  value: checkedProduct[
                                                      shopName]![index],
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      checkedProduct[shopName]![
                                                              index] =
                                                          newValue ?? false;
                                                    });
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 0.6)),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                        width: 110,
                                                        height: 110,
                                                        fit: BoxFit.fill,
                                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Đây là tên sản phẩm Đây là tên  tên sản phẩm Đây là tên",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  IntrinsicWidth(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Trắng quài đi taoTrắng quài đi taoTrắng quài đi taoTrắng quài đi tao",
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            ', XL',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Icon(Icons
                                                              .keyboard_arrow_down_outlined)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 30,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Row(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .dongSign,
                                                            color: Colors.red,
                                                            size: 17,
                                                          ),
                                                          Text(
                                                            "500.000",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1)),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {},
                                                                child:
                                                                    Container(
                                                                  height: double
                                                                      .infinity,
                                                                  decoration: const BoxDecoration(
                                                                      border: Border(
                                                                          right: BorderSide(
                                                                              color: Colors.grey,
                                                                              width: 1))),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .minus,
                                                                    color: Colors
                                                                            .grey[
                                                                        700],
                                                                    size: 13,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 20,
                                                              child:
                                                                  TextFormField(
                                                                decoration:
                                                                    const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                        contentPadding:
                                                                            EdgeInsets.zero),
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                textAlignVertical:
                                                                    TextAlignVertical
                                                                        .center,
                                                                cursorWidth: 1,
                                                                cursorHeight:
                                                                    13,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                              ),
                                                            )),
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {},
                                                                child:
                                                                    Container(
                                                                  height: double
                                                                      .infinity,
                                                                  decoration: const BoxDecoration(
                                                                      border: Border(
                                                                          left: BorderSide(
                                                                              color: Colors.grey,
                                                                              width: 1))),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .plus,
                                                                    color: Colors
                                                                            .grey[
                                                                        700],
                                                                    size: 13,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
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
                        );
                      }),
                ],
              ),
            ),
          ),
          // AppBar
          Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 10),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Icon trở về
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.brown,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {},
                      child: const SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giỏ hàng",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              " (100)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              editProduct = !editProduct;
                            });
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: const Text(
                              "Sửa",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: const Icon(
                              BoxIcons.bx_chat,
                              color: Colors.brown,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )),

          // Bottom AppBar
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          fillColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.brown;
                            }
                            return Colors.transparent;
                          }),
                          value: checkAllProduct,
                          onChanged: (newValue) {
                            setState(() {
                              checkAllProduct = newValue ?? false;
                              checkedShop = List.filled(
                                  checkedShop.length, newValue ?? false);
                              for (int i = 0; i <= checkedShop.length; i++) {
                                checkedProduct["Shop$i"] =
                                    List.filled(2, newValue ?? false);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text(
                          "Tất cả",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  editProduct
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 130,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("Lưu vào đã thích"),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Tổng thanh toán ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.dongSign,
                                          color: Colors.red,
                                          size: 15,
                                        ),
                                        Text(
                                          "500.000",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                          // maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  editProduct
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 45,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2, color: Colors.brown),
                          ),
                          child: const Text(
                            "Xóa",
                            style: TextStyle(
                              color: Colors.brown,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(CheckOutScreen.routeName);
                          },
                          child: Container(
                            height: 45,
                            width: 110,
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Mua hàng ",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  "(0)",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
