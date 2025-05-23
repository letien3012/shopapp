import 'package:flutter/material.dart';
import 'package:luanvan/ui/admin_mainscreen.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/category/search_in_category_screen.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/chat/chat_screen.dart';
import 'package:luanvan/ui/chatbot/chat_bot_screen.dart';
import 'package:luanvan/ui/checkout/add_addressline_screen.dart.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';
import 'package:luanvan/ui/checkout/choice_shipmethod_for_shop_screen.dart';
import 'package:luanvan/ui/checkout/edit_location_screen.dart';
import 'package:luanvan/ui/checkout/location_screen.dart';
import 'package:luanvan/ui/checkout/pick_location.dart';
import 'package:luanvan/ui/checkout/pick_location_checkout_screen.dart';
import 'package:luanvan/ui/category/all_categories_screen.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/home/home_screen.dart';
import 'package:luanvan/ui/home/shop_dashboard.dart';
import 'package:luanvan/ui/item/add_review_screen.dart';
import 'package:luanvan/ui/item/my_review_screen.dart';
import 'package:luanvan/ui/item/review_screen.dart';
import 'package:luanvan/ui/login/forgotpw_screen.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/login/singup_screen.dart';
import 'package:luanvan/ui/login/verify_screen.dart';
import 'package:luanvan/ui/mainscreen.dart';
import 'package:luanvan/ui/order/order_detail_screen.dart';
import 'package:luanvan/ui/order/order_screen.dart';
import 'package:luanvan/ui/order/order_success_screen.dart';
import 'package:luanvan/ui/screen/demo_screen.dart';
import 'package:luanvan/ui/search/search_image_result.dart';
import 'package:luanvan/ui/search/search_result_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';
import 'package:luanvan/ui/shop/baner/add_banner_screen.dart';
import 'package:luanvan/ui/shop/baner/edit_banner_screen.dart';
import 'package:luanvan/ui/shop/baner/my_banner_screen.dart';
import 'package:luanvan/ui/shop/category/add_category_screen.dart';
import 'package:luanvan/ui/shop/category/edit_category_screen.dart';
import 'package:luanvan/ui/shop/category/my_category_screen.dart';

import 'package:luanvan/ui/shop/chat/shop_chat_detail_screen.dart';
import 'package:luanvan/ui/shop/chat/shop_chat_screen.dart';
import 'package:luanvan/ui/shop/comment/reply_comment_screen.dart';
import 'package:luanvan/ui/shop/comment/shop_review_screen.dart';
import 'package:luanvan/ui/shop/dashboard/admin_home_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_detail_shop_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_prepared_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_shop_screen.dart';
import 'package:luanvan/ui/shop/order_manager/packing_slip_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_category_screen.dart';
import 'package:luanvan/ui/shop/product_manager/delivery_cost_screen.dart';
import 'package:luanvan/ui/shop/product_manager/details_product_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_variant_screen.dart';
import 'package:luanvan/ui/shop/product_manager/set_variant_info_screen.dart';
import 'package:luanvan/ui/shop/product_manager/ship_manager_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/change_shop_info_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/add_location_shop_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/edit_location_shop_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/location_shop_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/pick_location_order_screen.dart';
import 'package:luanvan/ui/shop/analysis/revenue_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/my_shop_screen.dart';
import 'package:luanvan/ui/shop/analysis/sales_analysis_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/setting_shop_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/add_location_sign_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_variant_screen.dart';
import 'package:luanvan/ui/shop/product_manager/my_product_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/add_shop_phone.dart';
import 'package:luanvan/ui/shop/sign_shop/ship_setting_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/sign_shop.dart';
import 'package:luanvan/ui/shop/sign_shop/start_shop.dart';
import 'package:luanvan/ui/shop/supplier/add_supplier.dart';
import 'package:luanvan/ui/shop/supplier/edit_supplier.dart';
import 'package:luanvan/ui/shop/supplier/my_suppier.dart';
import 'package:luanvan/ui/shop/user/my_user_screen.dart';
import 'package:luanvan/ui/shop/user/user_detail_screen.dart';
import 'package:luanvan/ui/shop/warehouse/add%20_import_receipt.dart';
import 'package:luanvan/ui/shop/warehouse/add_import_receipt_supplier.dart';
import 'package:luanvan/ui/shop/warehouse/edit_stock_detail_screen.dart';
import 'package:luanvan/ui/shop/warehouse/import_receipt_manager/detail_import_receipt.dart';
import 'package:luanvan/ui/shop/warehouse/import_receipt_manager/import_receipt_manager_screen.dart';
import 'package:luanvan/ui/shop/warehouse/my_watehouse_screen.dart';
import 'package:luanvan/ui/splashscreen.dart';
import 'package:luanvan/ui/user/change_account_info.dart';
import 'package:luanvan/ui/user/change_info/change_email.dart';
import 'package:luanvan/ui/user/change_info/change_name.dart';
import 'package:luanvan/ui/user/change_info/change_password.dart';
import 'package:luanvan/ui/user/change_info/change_phone.dart';
import 'package:luanvan/ui/user/change_info/change_username.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';
import 'package:luanvan/ui/user/favorite_product_screen.dart';
import 'package:luanvan/ui/user/user_screen.dart';

import 'ui/category/product_in_category_screen.dart';

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
  AddLocationShopSignShopScreen.routeName: (context) =>
      AddLocationShopSignShopScreen(),
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
  ShopChatScreen.routeName: (context) => ShopChatScreen(),
  ShopChatDetailScreen.routeName: (context) => ShopChatDetailScreen(),
  ShopDashboard.routeName: (context) => ShopDashboard(),
  MyReviewScreen.routeName: (context) => MyReviewScreen(),
  AddReviewScreen.routeName: (context) => AddReviewScreen(),
  PickLocationCheckoutScreen.routeName: (context) =>
      PickLocationCheckoutScreen(),
  LocationShopScreen.routeName: (context) => LocationShopScreen(),
  EditLocationShopScreen.routeName: (context) => EditLocationShopScreen(),
  AddLocationShopScreen.routeName: (context) => AddLocationShopScreen(),
  PickLocationOrderScreen.routeName: (context) => PickLocationOrderScreen(),
  RevenueScreen.routeName: (context) => RevenueScreen(),
  SalesAnalysisScreen.routeName: (context) => SalesAnalysisScreen(),
  AddShopPhone.routeName: (context) => AddShopPhone(),
  ShopReviewScreen.routeName: (context) => ShopReviewScreen(),
  ReplyCommentScreen.routeName: (context) => ReplyCommentScreen(),
  DemoScreen.routeName: (context) => DemoScreen(),
  AllCategoriesScreen.routeName: (context) => AllCategoriesScreen(),
  OrderPreparedScreen.routeName: (context) => OrderPreparedScreen(),
  PackingSlipScreen.routeName: (context) => PackingSlipScreen(),
  MyCategoryScreen.routeName: (context) => MyCategoryScreen(),
  EditCategoryScreen.routeName: (context) => EditCategoryScreen(),
  AddProductCategoryScreen.routeName: (context) => AddProductCategoryScreen(),
  MyBannerScreen.routeName: (context) => MyBannerScreen(),
  AddBannerScreen.routeName: (context) => AddBannerScreen(),
  EditBannerScreen.routeName: (context) => EditBannerScreen(),
  MyUserScreen.routeName: (context) => MyUserScreen(),
  UserDetailScreen.routeName: (context) => UserDetailScreen(),
  SearchImageResultScreen.routeName: (context) => SearchImageResultScreen(),
  AdminMainScreen.routeName: (context) => AdminMainScreen(),
  AdminHomeScreen.routeName: (context) => AdminHomeScreen(),
  ChangePassword.routeName: (context) => ChangePassword(),
  ProductInCategoryScreen.routeName: (context) => ProductInCategoryScreen(),
  SearchInCategoryScreen.routeName: (context) => SearchInCategoryScreen(),
  ChatbotScreen.routeName: (context) => ChatbotScreen(),
  FavoriteProductScreen.routeName: (context) => FavoriteProductScreen(),
  MyWarehouseScreen.routeName: (context) => MyWarehouseScreen(),
  MySupplierScreen.routeName: (context) => MySupplierScreen(),
  AddSupplierScreen.routeName: (context) => AddSupplierScreen(),
  EditSupplierScreen.routeName: (context) => EditSupplierScreen(),
  AddImportReceiptScreen.routeName: (context) => AddImportReceiptScreen(),
  AddImportReceiptSupplierScreen.routeName: (context) =>
      AddImportReceiptSupplierScreen(),
  EditStockDetailScreen.routeName: (context) => EditStockDetailScreen(),
  ImportReceiptManagerScreen.routeName: (context) =>
      ImportReceiptManagerScreen(),
  DetailImportReceiptScreen.routeName: (context) => DetailImportReceiptScreen(),
};
