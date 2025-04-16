import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/chat/shop_chat_screen.dart';
import 'package:luanvan/ui/shop/dashboard/admin_home_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/my_shop_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  static String routeName = 'admin_main_screen';
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  var _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AdminAuthenticated) {
        _currentIndex = 1;
        context
            .read<ShopBloc>()
            .add(FetchShopEventByShopId(authState.shop.shopId!));
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const AdminHomeScreen(),
            const ShopChatScreen(),
            MyShopScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(IconHelper.homeOutlineIcon, "Trang chủ", 0,
                  IconHelper.homeFilledIcon),
              _buildNavItem(IconHelper.chat_round_dots, "Tin nhắn", 1,
                  IconHelper.chat_round_dots_filled),
              _buildNavItem(IconHelper.userOutlineIcon, "Shop của tôi", 2,
                  IconHelper.userFilledIcon)
            ],
          ),
        ));
  }

  Widget _buildNavItem(
      String icon, String label, int index, String iconClicked) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isSelected ? iconClicked : icon,
            height: 25,
            width: 25,
            colorFilter: isSelected
                ? ColorFilter.mode(
                    Colors.brown,
                    BlendMode.srcIn,
                  )
                : ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.brown : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
