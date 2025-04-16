import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/shop/shop_manager/change_shop_info_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/location_shop_screen.dart';

class SettingShopScreen extends StatefulWidget {
  const SettingShopScreen({super.key});
  static String routeName = 'setting_shop';

  @override
  State<SettingShopScreen> createState() => _SettingShopScreenState();
}

class _SettingShopScreenState extends State<SettingShopScreen> {
  bool isClose = false;
  // Shop shop = Shop(
  //   userId: '',
  //   name: '',
  //   addresses: [],
  //   phoneNumber: '',
  //   email: '',
  //   submittedAt: DateTime.now(),
  //   isClose: false,
  //   isLocked: false,
  // );
  String shopId = '';
  @override
  void initState() {
    Future.microtask(() {
      shopId = ModalRoute.of(context)!.settings.arguments as String;
    });
    super.initState();
  }

  Future<bool> _showIsCloseConfirmationDialog() async {
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
                  "Người mua sẽ không thể đặt hàng trong khi Shop bạn tạm nghỉ bán. Bạn chắc chắn muốn bật tạm nghỉ bán chứ?"),
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
                          "Hủy",
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
                          "Bật",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoading) {
          return _buildLoading();
        } else if (shopState is ShopLoaded) {
          return _buildContent(context, shopState.shop);
        } else if (shopState is ShopError) {
          return _buildError(shopState.message);
        }
        return _buildInitializing();
      },
    ));
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Initializing...'));
  }

  // Chưa đăng nhập
  Widget _buildNotAuthenticated() {
    return const Center(child: Text("Chưa đăng nhập"));
  }

  // Nội dung chính
  Widget _buildContent(BuildContext context, Shop shop) {
    return Stack(
      children: [
        _buildBody(context, shop),
        _buildAppBar(context),
      ],
    );
  }

  // Phần body với danh sách thông tin tài khoản
  Widget _buildBody(BuildContext context, Shop shop) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 80),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.grey[200],
        child: Column(
          children: [
            _buildAccountItem(
              "Hồ sơ shop",
              onTap: () => Navigator.of(context).pushNamed(
                  ChangeShopInfoScreen.routeName,
                  arguments: shop.shopId),
            ),

            // _buildIsCloseItem(context, shop),
            _buildAccountItem(
              "Địa chỉ lấy hàng",
              onTap: () => Navigator.of(context).pushNamed(
                LocationShopScreen.routeName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mục thông tin tài khoản
  Widget _buildAccountItem(
    String title, {
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.2, color: Colors.grey),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  if (trailingText != null)
                    Text(
                      trailingText,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: trailingText == "Thiết lập ngay"
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mục thông tin tài khoản
  // Widget _buildIsCloseItem(BuildContext context, Shop shop) {
  //   return Container(
  //     height: 50,
  //     padding: const EdgeInsets.symmetric(horizontal: 10),
  //     width: double.infinity,
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border(
  //         bottom: BorderSide(width: 0.2, color: Colors.grey),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Chế độ tạm nghỉ',
  //           style: const TextStyle(fontWeight: FontWeight.w500),
  //         ),
  //         CupertinoSwitch(
  //           value: isClose,
  //           onChanged: (value) async {
  //             if (value) {
  //               if (await _showIsCloseConfirmationDialog()) {
  //                 isClose = value;
  //                 context
  //                     .read<ShopBloc>()
  //                     .add(UpdateShopEvent(shop.copyWith(isClose: isClose)));
  //               }
  //             } else {
  //               isClose = value;
  //               context
  //                   .read<ShopBloc>()
  //                   .add(UpdateShopEvent(shop.copyWith(isClose: isClose)));
  //             }
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  // AppBar
  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
            const Expanded(
              child: Text(
                "Thiết lập shop",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
