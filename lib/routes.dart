import 'package:flutter/material.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/home/home_screen.dart';
import 'package:luanvan/ui/item/review_screen.dart';
import 'package:luanvan/ui/login/forgotpw_screen.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/login/singup_screen.dart';
import 'package:luanvan/ui/login/verify_screen.dart';
import 'package:luanvan/ui/mainscreen.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';
import 'package:luanvan/ui/splashscreen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SigninScreen.routeName: (context) => const SigninScreen(),
  SingupScreen.routeName: (context) => const SingupScreen(),
  ForgotpwScreen.routeName: (context) => const ForgotpwScreen(),
  VerifyScreen.routeName: (context) => const VerifyScreen(),
  Mainscreen.routeName: (context) => const Mainscreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  DetaiItemScreen.routeName: (context) => const DetaiItemScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  SearchResultScreen.routeName: (context) => const SearchResultScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ReviewScreen.routeName: (context) => const ReviewScreen(),
  ChatScreen.routeName: (context) => const ChatScreen(),
};
