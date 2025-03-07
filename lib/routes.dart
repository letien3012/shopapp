import 'package:flutter/material.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/checkout/add_addressline_screen.dart.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';
import 'package:luanvan/ui/checkout/location_screen.dart';
import 'package:luanvan/ui/checkout/pick_location.dart';
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
import 'package:luanvan/ui/shop/add_location_shop_screen.dart';
import 'package:luanvan/ui/shop/ship_setting_screen.dart';
import 'package:luanvan/ui/shop/sign_shop.dart';
import 'package:luanvan/ui/shop/start_shop.dart';
import 'package:luanvan/ui/splashscreen.dart';
import 'package:luanvan/ui/user/change_account_info.dart';
import 'package:luanvan/ui/user/change_info/change_email.dart';
import 'package:luanvan/ui/user/change_info/change_name.dart';
import 'package:luanvan/ui/user/change_info/change_phone.dart';
import 'package:luanvan/ui/user/change_info/change_username.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';
import 'package:luanvan/ui/user/user_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SigninScreen.routeName: (context) => const SigninScreen(),
  SingupScreen.routeName: (context) => const SingupScreen(),
  ForgotpwScreen.routeName: (context) => const ForgotpwScreen(),
  VerifyScreen.routeName: (context) => const VerifyScreen(),
  MainScreen.routeName: (context) => const MainScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  DetaiItemScreen.routeName: (context) => const DetaiItemScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  SearchResultScreen.routeName: (context) => const SearchResultScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ReviewScreen.routeName: (context) => const ReviewScreen(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  ChatDetailScreen.routeName: (context) => const ChatDetailScreen(),
  CheckOutScreen.routeName: (context) => const CheckOutScreen(),
  LocationScreen.routeName: (context) => const LocationScreen(),
  AddLocationScreen.routeName: (context) => const AddLocationScreen(),
  PickLocation.routeName: (context) => const PickLocation(),
  AddAddresslineScreen.routeName: (context) => const AddAddresslineScreen(),
  UserScreen.routeName: (context) => UserScreen(),
  ChangeInfomationUser.routeName: (context) => ChangeInfomationUser(),
  ChangeAccountInfo.routeName: (context) => ChangeAccountInfo(),
  ChangeName.routeName: (context) => ChangeName(),
  ChangeUsername.routeName: (context) => ChangeUsername(),
  ChangePhone.routeName: (context) => ChangePhone(),
  ChangeEmail.routeName: (context) => ChangeEmail(),
  StartShop.routeName: (context) => StartShop(),
  SignShop.routeName: (context) => SignShop(),
  AddLocationShopScreen.routeName: (context) => AddLocationShopScreen(),
  ShipSettingScreen.routeName: (context) => ShipSettingScreen(),
};
