import 'package:flutter/material.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/shop/sign_shop/sign_shop.dart';

class StartShop extends StatefulWidget {
  const StartShop({super.key});
  static String routeName = 'start_shop';
  @override
  State<StartShop> createState() => _StartShopState();
}

class _StartShopState extends State<StartShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 90, bottom: 60),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    color: Colors.grey[200],
                  ),
                  Image.asset(
                    ImageHelper.start_shop_background,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 25, right: 25),
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      "Vui lòng cung cấp thông tin để thành lập tài khoản người bán",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
          // AppBar
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                        margin: EdgeInsets.only(bottom: 5),
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
                    const SizedBox(
                      height: 40,
                      child: Text(
                        "Chào mừng trở thành nhà bán hàng ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),

          // Bottom AppBar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                  width: 5,
                  color: Colors.grey[200]!,
                )),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Material(
                  color: Colors.brown,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(SignShop.routeName);
                    },
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    splashColor: Colors.transparent.withOpacity(0.2),
                    child: Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(10),
                      child: Container(
                        child: Text(
                          "Bắt đầu đăng ký",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
