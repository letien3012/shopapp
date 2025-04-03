import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/banner/banner_bloc.dart';
import 'package:luanvan/blocs/banner/banner_event.dart';
import 'package:luanvan/blocs/banner/banner_state.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/category/category_state.dart';
import 'package:luanvan/models/category.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/baner/edit_banner_screen.dart';
import 'package:luanvan/ui/shop/baner/add_banner_screen.dart';
import 'package:luanvan/ui/shop/product_manager/details_product_shop_screen.dart';
import 'package:luanvan/models/banner.dart' as model;

class MyBannerScreen extends StatefulWidget {
  const MyBannerScreen({super.key});
  static String routeName = "my_banner";

  @override
  State<MyBannerScreen> createState() => _MyBannerScreenState();
}

class _MyBannerScreenState extends State<MyBannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerBloc>().add(FetchBannersEvent());
    });
  }

  void _hideBanner(model.Banner banner) {
    context.read<BannerBloc>().add(UpdateBannerEvent(banner: banner));
  }

  void _editBanner(model.Banner banner) {
    Navigator.of(context).pushNamed(
      EditBannerScreen.routeName,
      arguments: banner,
    );
  }

  void _deleteBanner(String bannerId) {
    context.read<BannerBloc>().add(DeleteBannerEvent(id: bannerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, bannerState) {
          if (bannerState is BannerLoading) {
            return _buildLoading();
          } else if (bannerState is BannerLoaded) {
            return _buildBannerContent(context, bannerState.banners);
          } else if (bannerState is BannerError) {
            return _buildError(bannerState.message);
          }
          return _buildInitializing();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildBannerContent(BuildContext context, List<model.Banner> banners) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          padding: const EdgeInsets.only(top: 90, bottom: 60),
          child: _buildBannerList(banners),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: Text(
                        "Quản lý banner",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.search, color: Colors.brown, size: 30),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              IconHelper.chatIcon,
                              color: Colors.brown,
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  AddBannerScreen.routeName,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Thêm banner mới",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerList(List<model.Banner> banners) {
    banners.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (banners.isEmpty) {
      return Center(
        child: Text(
          "Không có banner",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, DetailsProductShopScreen.routeName,
                      arguments: banner.id);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    banner.imageUrl,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://via.placeholder.com/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildActionButton(
                      banner.isHidden ? "Hiện" : "Ẩn",
                      Colors.white,
                      Colors.black,
                      banner.isHidden
                          ? () => _hideBanner(banner.copyWith(isHidden: false))
                          : () => _hideBanner(banner.copyWith(isHidden: true))),
                  const SizedBox(width: 10),
                  _buildActionButton("Sửa", Colors.brown, Colors.white,
                      () => _editBanner(banner)),
                  const SizedBox(width: 10),
                  _buildActionButton("Xóa", Colors.red[800]!, Colors.white,
                      () => _deleteBanner(banner.id)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      child: InkWell(
        splashColor: bgColor.withOpacity(0.2),
        highlightColor: bgColor.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ),
    );
  }
}
