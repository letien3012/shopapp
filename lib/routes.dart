import 'package:flutter/material.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/checkout/add_addressline_screen.dart.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';
import 'package:luanvan/ui/checkout/choice_shipmethod_for_shop_screen.dart';
import 'package:luanvan/ui/checkout/edit_location_screen.dart';
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
import 'package:luanvan/ui/order/order_detail_screen.dart';
import 'package:luanvan/ui/order/order_screen.dart';
import 'package:luanvan/ui/order/order_success_screen.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_detail_shop_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_category_screen.dart';
import 'package:luanvan/ui/shop/product_manager/delivery_cost_screen.dart';
import 'package:luanvan/ui/shop/product_manager/details_product_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_variant_screen.dart';
import 'package:luanvan/ui/shop/product_manager/set_variant_info_screen.dart';
import 'package:luanvan/ui/shop/product_manager/ship_manager_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/change_shop_info_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/setting_shop_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/add_location_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_variant_screen.dart';
import 'package:luanvan/ui/shop/product_manager/my_product_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/my_shop_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/ship_setting_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/sign_shop.dart';
import 'package:luanvan/ui/shop/sign_shop/start_shop.dart';
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
  DetailsProductShopScreen.routeName: (context) =>
      const DetailsProductShopScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  SearchResultScreen.routeName: (context) => const SearchResultScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ReviewScreen.routeName: (context) => const ReviewScreen(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  ChatDetailScreen.routeName: (context) => const ChatDetailScreen(),
  CheckOutScreen.routeName: (context) => const CheckOutScreen(),
  LocationScreen.routeName: (context) => const LocationScreen(),
  AddLocationScreen.routeName: (context) => const AddLocationScreen(),
  EditLocationScreen.routeName: (context) => const EditLocationScreen(),
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
  MyShopScreen.routeName: (context) => MyShopScreen(),
  MyProductScreen.routeName: (context) => MyProductScreen(),
  AddProductScreen.routeName: (context) => AddProductScreen(),
  EditProductScreen.routeName: (context) => EditProductScreen(),
  AddCategoryScreen.routeName: (context) => AddCategoryScreen(),
  AddVariantScreen.routeName: (context) => AddVariantScreen(),
  SetVariantInfoScreen.routeName: (context) => SetVariantInfoScreen(),
  EditVariantScreen.routeName: (context) => EditVariantScreen(),
  SettingShopScreen.routeName: (context) => SettingShopScreen(),
  ChangeShopInfoScreen.routeName: (context) => ChangeShopInfoScreen(),
  ShipManagerScreen.routeName: (context) => ShipManagerScreen(),
  DeliveryCostScreen.routeName: (context) => DeliveryCostScreen(),
  ChoiceShipmethodForShopScreen.routeName: (context) =>
      ChoiceShipmethodForShopScreen(),
  OrderSuccessScreen.routeName: (context) => OrderSuccessScreen(),
  OrderScreen.routeName: (context) => OrderScreen(),
  OrderShopScreen.routeName: (context) => OrderShopScreen(),
  OrderDetailScreen.routeName: (context) => OrderDetailScreen(),
  OrderDetailShopScreen.routeName: (context) => OrderDetailShopScreen(),
};
