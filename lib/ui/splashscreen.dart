import 'package:flutter/material.dart';
import 'package:luanvan/ui/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String routeName = 'splash_screen';
  @override
  State<SplashScreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        child: Center(child: Text('welcome')),
        onTap: () {
          Navigator.of(context).pushNamed(MainScreen.routeName);
        },
      ),
    );
  }
}
