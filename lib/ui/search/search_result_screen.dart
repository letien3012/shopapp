import 'package:flutter/material.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});
  static String routeName = "search_result_screen";

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  bool _isRelate = true;
  bool _isNewest = false;
  bool _isBestSelling = false;
  bool isPlaceSellingExpand = false;
  int _isPrice = 0;
  List<String> placeSelling = [
    "TP. Hồ Chí Minh",
    "Hà Nội",
    "Đà Nẵng",
    "Đồng Nai",
    "Bình Dương",
    "Thái Nguyên",
    "Vĩnh Phúc",
    "Hải Phòng",
    "Hưng Yên",
    "Bắc Ninh",
    "Quảng Ninh",
    "Hải Dương",
    "Nam Định",
    "Cần Thơ",
    "Phú Thọ",
    "Bà Rịa - Vũng Tàu",
    "Đắk Lắk",
    "Thanh Hóa",
    "Thái Bình",
    "An Giang"
  ];
  List<String> rating = [
    "5 sao",
    "Từ 4 sao",
    "Từ 3 sao",
    "Từ 2 sao",
    "Từ 1 sao"
  ];
  List<String> price = [
    "0-100k",
    "100k-200k",
    "200k-300k",
  ];
  int selectedRating = -1;
  int selectedPrice = -1;
  Set<int> selectedFiltersPlace = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Row(
          children: [
            Container(
              color: Colors.white,
              child: Align(
                alignment: const Alignment(1, 0.6),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.brown,
                      size: 30,
                    )),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Align(
              alignment: const Alignment(1, 0.6),
              child: Container(
                alignment: Alignment.centerLeft,
                height: 46,
                width: 280,
                child: TextField(
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: 'Từ khóa đã nhập',
                      hintStyle:
                          const TextStyle(fontSize: 15, color: Colors.grey),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined),
                      ),
                      suffixIconColor: Colors.brown),
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.bottom,
                  readOnly: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                ),
              ),
            ),
            Align(
              alignment: const Alignment(1, 0.6),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                child: Container(
                  height: 46,
                  width: 60,
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.brown,
                              size: 30,
                            )),
                      ),
                      const Positioned(
                        left: 30,
                        top: 25,
                        child: Text(
                          "Lọc",
                          style: TextStyle(fontSize: 13, color: Colors.brown),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (!_isRelate) {
                          _isRelate = true;
                          _isNewest = false;
                          _isBestSelling = false;
                          _isPrice = 0;
                        }
                      });
                    },
                    child: Text(
                      "Liên quan",
                      style: TextStyle(
                          fontSize: 15,
                          color: _isRelate ? Colors.brown : Colors.grey),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (!_isNewest) {
                          _isRelate = false;
                          _isBestSelling = false;
                          _isNewest = true;
                          _isPrice = 0;
                        }
                      });
                    },
                    child: Text(
                      "Mới nhất",
                      style: TextStyle(
                          fontSize: 15,
                          color: _isNewest ? Colors.brown : Colors.grey),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (!_isBestSelling) {
                          _isRelate = false;
                          _isNewest = false;
                          _isBestSelling = true;
                          _isPrice = 0;
                        }
                      });
                    },
                    child: Text(
                      "Bán chạy",
                      style: TextStyle(
                          fontSize: 15,
                          color: _isBestSelling ? Colors.brown : Colors.grey),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRelate = false;
                        _isNewest = false;
                        _isBestSelling = false;
                        if ((_isPrice + 1) % 3 == 0)
                          _isPrice = 1;
                        else {
                          _isPrice = _isPrice + 1;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "Giá",
                          style: TextStyle(
                              fontSize: 15,
                              color: _isPrice % 3 != 0
                                  ? Colors.brown
                                  : Colors.grey),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        _isPrice == 0
                            ? const SizedBox(
                                height: 50,
                                width: 20,
                                child: Stack(
                                  fit: StackFit.passthrough,
                                  children: [
                                    Positioned(
                                      top: 5,
                                      child: Icon(
                                        Icons.keyboard_arrow_up_outlined,
                                        size: 17,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      child: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 17,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Icon(
                                _isPrice == 1
                                    ? Icons.arrow_upward_outlined
                                    : Icons.arrow_downward_outlined,
                                size: 15,
                                color: Colors.brown,
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              color: Colors.grey[200],
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 290
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
                                            fontSize: 16, color: Colors.red),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Đã bán 6.1k',
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                      ),
                                      Text(
                                        "Hồ Chí Minh",
                                        style: TextStyle(fontSize: 10),
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
            )
          ],
        ),
      ),
      // Drawer bên phải khi mở bộ lọc
      endDrawer: Drawer(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey[200],
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: const Text(
                  "Bộ lọc tìm kiếm",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              //Nơi bán

              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nơi bán",
                          style: TextStyle(fontSize: 16),
                        ),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              isPlaceSellingExpand ? placeSelling.length : 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 7,
                                  crossAxisSpacing: 7,
                                  mainAxisExtent: 40),
                          itemBuilder: (context, index) {
                            bool isSelected =
                                selectedFiltersPlace.contains(index);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedFiltersPlace.remove(index);
                                  } else {
                                    selectedFiltersPlace.add(index);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                        color: isSelected
                                            ? Colors.brown
                                            : Colors.transparent,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(8)),
                                alignment: Alignment.center,
                                child: Text(
                                  placeSelling[index],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.brown
                                          : Colors.black),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPlaceSellingExpand = !isPlaceSellingExpand;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 1,
                        color: Colors.grey,
                      ))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isPlaceSellingExpand ? "Thu gọn" : "Xem thêm"),
                            Icon(isPlaceSellingExpand
                                ? Icons.keyboard_arrow_up_outlined
                                : Icons.keyboard_arrow_down_outlined)
                          ]),
                    ),
                  )
                ],
              ),
              //Lọc theo khoảng giá
              Container(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Khoảng giá (đ)",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 45,
                            width: 130,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.grey[50]),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: "Tối thiểu",
                                hintStyle:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 3,
                            color: Colors.grey[500],
                          ),
                          Container(
                            height: 45,
                            width: 130,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.grey[50]),
                            child: TextField(
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: "Tối đa",
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 7,
                                  mainAxisExtent: 40),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPrice == index
                                      ? selectedPrice = -1
                                      : selectedPrice = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                        color: index == selectedPrice
                                            ? Colors.brown
                                            : Colors.transparent,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(8)),
                                alignment: Alignment.center,
                                child: Text(
                                  price[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: index == selectedPrice
                                        ? Colors.brown
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),
              // Lọc theo đánh giá shop
              Container(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Đánh giá",
                      style: TextStyle(fontSize: 16),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 5,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 7,
                              crossAxisSpacing: 7,
                              mainAxisExtent: 40),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating == index
                                  ? selectedRating = -1
                                  : selectedRating = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                    color: index == selectedRating
                                        ? Colors.brown
                                        : Colors.transparent,
                                    width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text(
                              rating[index],
                              style: TextStyle(
                                fontSize: 14,
                                color: index == selectedRating
                                    ? Colors.brown
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
