import 'package:flutter/material.dart';
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
  int _isPrice = 0;
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
            )
          ],
        ),
      ),
    );
  }
}
