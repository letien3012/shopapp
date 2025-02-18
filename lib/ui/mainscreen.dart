import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/ui/home/home_screen.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});
  static String routeName = 'main-screen';
  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  var _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [HomeScreen()],
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(Icons.home, "Trang chủ", 0, Icons.home_filled),
              _buildNavItem(Icons.live_help_outlined, "Hỏi đáp", 1,
                  Icons.live_help_sharp),
              _buildNavItem(BoxIcons.bx_chat, "Tin nhắn", 2, BoxIcons.bx_chat),
              _buildNavItem(Icons.shopping_cart_outlined, "Giỏ hàng", 3,
                  Icons.shopping_cart_sharp),
              _buildNavItem(Icons.supervised_user_circle_outlined, "Tôi", 4,
                  Icons.supervised_user_circle_sharp)
            ],
          ),
        ));
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, IconData iconClicked) {
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
          Icon(
            isSelected ? iconClicked : icon,
            size: 30,
            color: isSelected ? Colors.brown : Colors.black87,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.brown : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
