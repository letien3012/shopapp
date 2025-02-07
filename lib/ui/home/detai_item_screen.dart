import 'package:flutter/material.dart';

class DetaiItemScreen extends StatefulWidget {
  const DetaiItemScreen({super.key});
  static String routeName = 'Detail_item';
  @override
  State<DetaiItemScreen> createState() => _DetaiItemScreenState();
}

class _DetaiItemScreenState extends State<DetaiItemScreen> {
  final PageController _imageController = PageController();
  int _currentImage = 0;
  bool _isExpanded = false;
  final GlobalKey _details = GlobalKey();
  @override
  void initState() {
    super.initState();
    _imageController.addListener(() {
      setState(() {
        _currentImage = _imageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: 350,
                width: double.infinity,
                child: Stack(
                  children: [
                    PageView.builder(
                        controller: _imageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color:
                                (index % 2 == 0) ? Colors.amber : Colors.blue,
                          );
                        }),
                    Positioned(
                        right: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(221, 31, 30, 30),
                              borderRadius: BorderRadius.circular(13)),
                          width: 50,
                          height: 25,
                          child: Center(
                            child: Text(
                              '${_currentImage + 1}/2',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                  ],
                )),
            Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'đ100.000.000',
                    style: TextStyle(
                        fontSize: 20, color: Color.fromARGB(255, 151, 14, 4)),
                  ),
                  Text('Đã bán 100k')
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm Đây là tên sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 10,
              width: double.infinity,
              color: Colors.grey[200],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Đánh giá sản phẩm"),
                          Row(
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
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '5/5',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 143, 28, 20)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '(10k đánh giá)',
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          )
                        ],
                      ),
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Xem tất cả >',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 151, 26, 18)),
                          ))
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('leminhtien'),
                                        Row(
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
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.favorite_border_outlined),
                                      onPressed: () {},
                                    )
                                  ],
                                ),
                                const Text(
                                    'Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng'),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('leminhtien'),
                                        Row(
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
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.favorite_border_outlined),
                                      onPressed: () {},
                                    )
                                  ],
                                ),
                                const Text(
                                    'Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng Bình luận của khách hàng'),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                    Image.network(
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain,
                                        'https://product.hstatic.net/200000690725/product/fstp003-wh-7_53580331133_o_208c454df2584470a1aaf98c7e718c6d_master.jpg'),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.3))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Chi tiết sản phẩm",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Xem chi tiết",
                            style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.none,
                                color: Colors.black),
                          ))
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mô tả sản phẩm",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _isExpanded
                            ? (_details.currentContext!.findRenderObject()
                                    as RenderBox)
                                .size
                                .height
                            : 100,
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Text(
                            key: _details,
                            "Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩmĐây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm Đây là mô tả sản phẩm",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.black, width: 0.5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? "Thu gọn" : "Xem thêm ",
                      style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_outlined
                          : Icons.keyboard_arrow_down_outlined,
                      size: 20,
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: 50,
                    color: Colors.black45,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Các sản phẩm tương tự",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 1,
                    width: 50,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    GridView.builder(
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
                                      fit: BoxFit.contain,
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
                                                  fontSize: 16,
                                                  color: Colors.red),
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
            ),
          ],
        ),
      ),
    );
  }
}
