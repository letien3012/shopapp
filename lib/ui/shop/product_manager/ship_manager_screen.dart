import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class ShipManagerScreen extends StatefulWidget {
  const ShipManagerScreen({super.key});
  static String routeName = "ship_manager";

  @override
  State<ShipManagerScreen> createState() => _ShipManagerScreenState();
}

class _ShipManagerScreenState extends State<ShipManagerScreen> {
  bool isFastEnabled = false;
  bool isEconomyEnabled = false;
  bool isExpress = false;
  Shop shop = Shop(
    userId: '',
    name: '',
    addresses: [],
    phoneNumber: '',
    email: '',
    submittedAt: DateTime.now(),
    isClose: false,
    isLocked: false,
    shippingMethods: [],
  );

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: const Text(
                  "Bạn có chắc muốn tắt phương thức vận chuyển này?"),
              titleTextStyle: TextStyle(fontSize: 14, color: Colors.black),
              actions: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.3, color: Colors.grey),
                            right: BorderSide(width: 0.3, color: Colors.grey)),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          "Thoát",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 0.3, color: Colors.grey),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Tắt",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                  ],
                )
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _showCannotDisableAllDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        Timer(Duration(seconds: 1), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black87,
            ),
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  IconHelper.warning,
                  height: 40,
                  width: 40,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  "Phải có ít nhất 1 phương thức vận chuyển",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero, // Xóa padding mặc định của actions
          actions: [], // Không cần nút, tự động đóng
        );
      },
    );
  }

  bool _isAtLeastOneMethodEnabled() {
    return isEconomyEnabled || isFastEnabled || isExpress;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    shop = ModalRoute.of(context)?.settings.arguments as Shop;
    isEconomyEnabled = shop.shippingMethods[0].isEnabled;
    isFastEnabled = shop.shippingMethods[1].isEnabled;
    isExpress = shop.shippingMethods[2].isEnabled;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'isFastEnabled': isFastEnabled,
          'isEconomyEnabled': isEconomyEnabled,
          'isExpress': isExpress
        });
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[200],
                padding: const EdgeInsets.only(
                    top: 90, bottom: 20, left: 10, right: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Tiết Kiệm
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Tiết Kiệm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển với mức phí cạnh tranh thấp nhất",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isEconomyEnabled,
                            onChanged: (value) async {
                              if (!value) {
                                // Nếu chỉ còn "Tiết Kiệm" đang bật, không cho tắt
                                if (!isFastEnabled && !isExpress) {
                                  await _showCannotDisableAllDialog();
                                  return;
                                }
                                if (await _showConfirmationDialog()) {
                                  final updateShip = shop.shippingMethods[0]
                                      .copyWith(isEnabled: value);
                                  shop.shippingMethods[0] = updateShip;
                                  context
                                      .read<ShopBloc>()
                                      .add(UpdateShopEvent(shop));
                                  setState(() {
                                    isEconomyEnabled = value;
                                  });
                                }
                              } else {
                                final updateShip = shop.shippingMethods[0]
                                    .copyWith(isEnabled: value);
                                shop.shippingMethods[0] = updateShip;
                                context
                                    .read<ShopBloc>()
                                    .add(UpdateShopEvent(shop));
                                setState(() {
                                  isEconomyEnabled = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nhanh
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Nhanh",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển chuyên nghiệp, nhanh chóng và đáng tin cậy",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isFastEnabled,
                            onChanged: (value) async {
                              if (!value) {
                                // Nếu chỉ còn "Nhanh" đang bật, không cho tắt
                                if (!isEconomyEnabled && !isExpress) {
                                  await _showCannotDisableAllDialog();
                                  return;
                                }
                                if (await _showConfirmationDialog()) {
                                  final updateShip = shop.shippingMethods[1]
                                      .copyWith(isEnabled: value);
                                  shop.shippingMethods[1] = updateShip;
                                  context
                                      .read<ShopBloc>()
                                      .add(UpdateShopEvent(shop));
                                  setState(() {
                                    isFastEnabled = value;
                                  });
                                }
                              } else {
                                final updateShip = shop.shippingMethods[1]
                                    .copyWith(isEnabled: value);
                                shop.shippingMethods[1] = updateShip;
                                context
                                    .read<ShopBloc>()
                                    .add(UpdateShopEvent(shop));
                                setState(() {
                                  isFastEnabled = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Hỏa tốc
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Hỏa tốc",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển nhanh nhất",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isExpress,
                            onChanged: (value) async {
                              if (!value) {
                                // Nếu chỉ còn "Hỏa tốc" đang bật, không cho tắt
                                if (!isEconomyEnabled && !isFastEnabled) {
                                  await _showCannotDisableAllDialog();
                                  return;
                                }
                                if (await _showConfirmationDialog()) {
                                  final updateShip = shop.shippingMethods[2]
                                      .copyWith(isEnabled: value);
                                  shop.shippingMethods[2] = updateShip;
                                  context
                                      .read<ShopBloc>()
                                      .add(UpdateShopEvent(shop));
                                  setState(() {
                                    isExpress = value;
                                  });
                                }
                              } else {
                                final updateShip = shop.shippingMethods[2]
                                    .copyWith(isEnabled: value);
                                shop.shippingMethods[2] = updateShip;
                                context
                                    .read<ShopBloc>()
                                    .add(UpdateShopEvent(shop));
                                setState(() {
                                  isExpress = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'isFastEnabled': isFastEnabled,
                          'isEconomyEnabled': isEconomyEnabled,
                          'isExpress': isExpress
                        });
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
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Phương thức vận chuyển",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
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
    );
  }
}
