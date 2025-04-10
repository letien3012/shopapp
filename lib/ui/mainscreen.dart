import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/category/all_categories_screen.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/chatbot/chat_bot_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/home_screen.dart';
import 'package:luanvan/ui/shop/category/my_category_screen.dart';
import 'package:luanvan/ui/user/user_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String routeName = 'main_screen';
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
            AllCategoriesScreen(),
            ChatbotScreen(),
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
              _buildNavItem(IconHelper.category_outline, "Danh mục", 1,
                  IconHelper.category_filled),
              _buildNavItem(
                  IconHelper.bot_outline, "Chatbot", 2, IconHelper.bot_filled),
              _buildNavItem(IconHelper.chat_round_dots, "Tin nhắn", 3,
                  IconHelper.chat_round_dots_filled),
              _buildNavItem(IconHelper.userOutlineIcon, "Tôi", 4,
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
