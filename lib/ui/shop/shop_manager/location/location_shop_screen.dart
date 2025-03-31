import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/edit_location_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/add_location_shop_screen.dart';

class LocationShopScreen extends StatefulWidget {
  const LocationShopScreen({super.key});
  static String routeName = "location_shop_screen";
  @override
  State<LocationShopScreen> createState() => _LocationShopScreenState();
}

class _LocationShopScreenState extends State<LocationShopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthLoading) {
          return _buildLoading();
        } else if (state is AuthAuthenticated) {
          return BlocBuilder<ShopBloc, ShopState>(
            builder: (context, shopState) {
              if (shopState is ShopLoading) {
                return _buildLoading();
              } else if (shopState is ShopLoaded) {
                return _buildShopContent(context, shopState.shop);
              } else if (shopState is ShopError) {
                return _buildError(shopState.message);
              }
              return _buildInitializing();
            },
          );
        } else if (state is AuthError) {
          return _buildError(state.message);
        } else if (state is AuthUnauthenticated) {
          return _buildNotAuthenticated();
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
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildNotAuthenticated() {
    return const Center(child: Text("Chưa đăng nhập"));
  }

  Widget _buildShopContent(BuildContext context, Shop shop) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              padding: const EdgeInsets.only(top: 90, bottom: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    color: Colors.grey[200],
                    height: 20,
                    child: Text("Địa chỉ lấy hàng"),
                  ),
                  // Địa chỉ
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: shop.addresses.length,
                    itemBuilder: (context, index) => Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            EditLocationScreen.routeName,
                            arguments: {"index": index, "shop": shop},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[200]!),
                              top: BorderSide(
                                  width: 1, color: Colors.grey[200]!),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 60,
                                alignment: Alignment.topCenter,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          shop.addresses[index].receiverName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          shop.addresses[index].receiverPhone,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      shop.addresses[index].addressLine,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      "${shop.addresses[index].ward}, ${shop.addresses[index].district}, ${shop.addresses[index].city}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    index == 0
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            height: 30,
                                            width: 100,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.brown)),
                                            child: Text(
                                              'Mặc định',
                                              style: TextStyle(
                                                  color: Colors.brown),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AddLocationShopScreen.routeName,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Colors.grey[200]!,
                            ),
                            top: BorderSide(
                              width: 1,
                              color: Colors.grey[200]!,
                            ),
                          )),
                      height: 60,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HeroIcons.plus_circle,
                            color: Colors.brown,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Thêm địa chỉ mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Appbar
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
                  const SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Địa chỉ lấy hàng",
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
    );
  }
}
