import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  static String routeName = "user_screen";
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.brown,
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        height: 30,
                        width: 130,
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              HeroIcons.building_storefront,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Bắt đầu bán",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // GestureDetector(
                          //   onTap: () {},
                          //   child: const Icon(
                          //     HeroIcons.cog_8_tooth,
                          //     size: 30,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   width: 10,
                          // ),
                          SizedBox(
                            height: 40,
                            width: 50,
                            child: Stack(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 30,
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
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            BoxIcons.bx_chat,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 55,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 55,
                          width: 70,
                          child: Stack(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  'https://img.freepik.com/premium-vector/luxury-lch-logo-design-elegant-letter-lch-monogram-logo-minimalist-polygon-lch-logo-design-template_1101554-79801.jpg',
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text(
                                    "lỗi",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 35,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  height: 25,
                                  width: 25,
                                  child: const Icon(
                                    FontAwesome.pen_solid,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "username",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "4 người theo dõi",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Đơn mua",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Text(
                              "Xem tất cả",
                              style: TextStyle(),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: const Column(
                          children: [
                            Icon(
                              FontAwesome.wallet_solid,
                              size: 35,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("Chờ xác nhận",
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: const Column(
                          children: [
                            Icon(
                              HeroIcons.inbox_stack,
                              size: 35,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("Chờ lấy hàng",
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: const Column(
                          children: [
                            Icon(
                              FontAwesome.truck_solid,
                              size: 35,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Đang giao hàng",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: const Column(
                          children: [
                            Icon(
                              Icons.stars_outlined,
                              size: 35,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Đánh giá",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              width: double.infinity,
              color: Colors.grey[200],
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[200]!),
                  )),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tài khoản và bảo mật",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[200]!),
                  )),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Địa chỉ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[200]!),
                  )),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tiêu chuẩn cộng đồng",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[200]!),
                  )),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sản phẩm đã thích",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[200]!),
                  )),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Yêu cầu xóa tài khoản",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              height: 70,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              color: Colors.grey[200],
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(width: 1, color: Colors.black)),
                  child: const Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
