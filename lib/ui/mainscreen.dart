import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/home_screen.dart';
import 'package:luanvan/ui/user/user_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String routeName = 'main_screen';

  static var user = UserInfoModel(
    id: "1",
    name: "Lê Minh Tiền",
    email: "leminhtien3012@gmail.com",
    phone: "0817124418",
    avataUrl:
        "https://img.freepik.com/premium-vector/luxury-lch-logo-design-elegant-letter-lch-monogram-logo-minimalist-polygon-lch-logo-design-template_1101554-79801.jpg",
    gender: Gender.male,
    date: "30/12/2003",
    userName: "letien3012",
  );
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const HomeScreen(),
            const ChatScreen(),
            UserScreen(),
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
              _buildNavItem(IconHelper.questionOutlineIcon, "Hỏi đáp", 1,
                  IconHelper.questionFilledIcon),
              _buildNavItem(IconHelper.cartIcon, "Tin nhắn", 2,
                  IconHelper.cartFilledIcon),
              _buildNavItem(IconHelper.userOutlineIcon, "Tôi", 3,
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
