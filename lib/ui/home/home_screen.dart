import 'package:flutter/material.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routeName = "home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(SearchScreen.routeName);
          },
          child: Container(
              color: Colors.brown,
              height: 100,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 45, left: 15, right: 10, bottom: 10),
                    height: 80,
                    width: 321,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search),
                        ),
                        const Expanded(
                          child: Text(
                            "tiền đẹp trai",
                            style: TextStyle(color: Colors.brown),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt_outlined))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 45, bottom: 10),
                    height: 50,
                    width: 50,
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          children: [
            const Text(
              'tiền đẹp trai',
              style: TextStyle(fontSize: 50),
            ),
            GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
    );
    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       Container(
    //           color: Colors.brown,
    //           height: 100,
    //           child: Row(
    //             children: [
    //               Container(
    //                 margin: const EdgeInsets.only(
    //                     top: 45, left: 15, right: 10, bottom: 10),
    //                 height: 80,
    //                 width: 321,
    //                 decoration: const BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.all(Radius.circular(15))),
    //                 child: Row(
    //                   children: [
    //                     IconButton(
    //                       onPressed: () {},
    //                       icon: Icon(Icons.search),
    //                     ),
    //                     const Expanded(
    //                       child: Text(
    //                         "hahha",
    //                         style: TextStyle(color: Colors.brown),
    //                         textAlign: TextAlign.start,
    //                       ),
    //                     ),
    //                     IconButton(
    //                         onPressed: () {},
    //                         icon: const Icon(Icons.camera_alt_outlined))
    //                   ],
    //                 ),
    //               ),
    //               Container(
    //                 margin: const EdgeInsets.only(top: 45, bottom: 10),
    //                 height: 50,
    //                 width: 50,
    //                 child: const Icon(
    //                   Icons.shopping_cart_outlined,
    //                   size: 30,
    //                   color: Colors.white,
    //                 ),
    //               )
    //             ],
    //           )),
    //       Positioned(
    //         top: 100,
    //         child: GridView.builder(
    //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                 crossAxisCount: 2),
    //             itemCount: 10,
    //             itemBuilder: (BuildContext context, int index) {
    //               return Container(
    //                 color: Colors.black,
    //               );
    //             }),
    //       )
    //     ],
    //   ),
    // );
  }
}
