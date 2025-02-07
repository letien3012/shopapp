import 'package:flutter/material.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static String routeName = "search_screen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GlobalKey _searcHistory = GlobalKey();
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Row(
          children: [
            Container(
              color: Colors.white,
              child: Align(
                alignment: const Alignment(1, 0.6),
                child: IconButton(
                    onPressed: () {},
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
                width: 290,
                child: TextField(
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      hintText: 'Nhập từ khóa',
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
                  autofocus: true,
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
                  color: Colors.brown,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(SearchResultScreen.routeName);
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 30,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              ListView.builder(
                key: _searcHistory,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _isExpanded ? 10 : 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "abc",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.grey, width: 0.5))),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5))),
                  child: Text(
                    _isExpanded ? "Xóa tất cả lịch sử" : "Xem thêm",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Container(
                height: 10,
                width: double.infinity,
                color: Colors.grey[200],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Gợi ý tìm kiếm",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: 230
                                // childAspectRatio: 0.8,
                                ),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(DetaiItemScreen.routeName);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                      width: double.infinity,
                                      height: 170,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
