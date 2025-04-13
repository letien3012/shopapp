import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luanvan/blocs/allmessage/all_message_bloc.dart';
import 'package:luanvan/blocs/alluser/all_user_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/banner/banner_bloc.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat_room/chat_room_bloc.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_bloc.dart';
import 'package:luanvan/blocs/checkcartproduct/check_product_checkout_bloc.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_bloc.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop_search/list_shop_search_bloc.dart';
import 'package:luanvan/blocs/list_user/list_user_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbycategory/listproductbycategory_bloc.dart';
import 'package:luanvan/blocs/listproductinshopbloc/listproductinshop_bloc.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/productcomment/product_comment_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_bloc.dart';
import 'package:luanvan/blocs/search/search_bloc.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_bloc.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/user_chat/user_chat_bloc.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_bloc.dart';
import 'package:luanvan/di.dart';
import 'package:luanvan/routes.dart';
import 'package:luanvan/services/auth_service.dart';
import 'package:luanvan/services/banner_service.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/category_service.dart';
import 'package:luanvan/services/chat_service.dart';
import 'package:luanvan/services/comment_service.dart';
import 'package:luanvan/services/image_feature_service.dart';
import 'package:luanvan/services/import_receipt_service.dart';
import 'package:luanvan/services/order_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/search_service.dart';
import 'package:luanvan/services/shop_service.dart';
import 'package:luanvan/services/supplier_service.dart';
import 'package:luanvan/services/user_service.dart';
import 'package:luanvan/ui/splashscreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/home/home_bloc.dart';
import 'package:luanvan/services/home_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ui.PlatformDispatcher.instance.onMetricsChanged = () {
    final double refreshRate =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  };
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  setupDependencies();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await SharedPreferences.getInstance();
  await dotenv.load();
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(UserService()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(AuthService()),
        ),
        BlocProvider(
          create: (context) => ShopBloc(ShopService()),
        ),
        BlocProvider(
          create: (context) =>
              ProductBloc(ProductService(), ListProductBloc(ProductService())),
        ),
        BlocProvider(
          create: (context) => ListProductBloc(ProductService()),
        ),
        BlocProvider(
          create: (context) => CartBloc(CartService()),
        ),
        BlocProvider(
          create: (context) => ChatRoomBloc(ChatService()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(ChatService()),
        ),
        BlocProvider<ProductCartBloc>(
          create: (context) => ProductCartBloc(ProductService()),
        ),
        BlocProvider<ListShopBloc>(
          create: (context) => ListShopBloc(ShopService()),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(OrderService()),
        ),
        BlocProvider<ProductOrderBloc>(
          create: (context) => ProductOrderBloc(ProductService()),
        ),
        BlocProvider<ListUserBloc>(
          create: (context) => ListUserBloc(UserService()),
        ),
        BlocProvider<UserChatBloc>(
          create: (context) => UserChatBloc(UserService()),
        ),
        BlocProvider<CommentBloc>(
          create: (context) => CommentBloc(CommentService()),
        ),
        BlocProvider<ListUserCommentBloc>(
          create: (context) => ListUserCommentBloc(UserService()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(SearchService()),
        ),
        BlocProvider<CheckBloc>(
          create: (context) => CheckBloc(AuthService()),
        ),
        BlocProvider<ListShopSearchBloc>(
          create: (context) => ListShopSearchBloc(ShopService()),
        ),
        BlocProvider<ListproductinshopBloc>(
          create: (context) => ListproductinshopBloc(ProductService()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(HomeService()),
        ),
        BlocProvider<ProductCommentBloc>(
          create: (context) => ProductCommentBloc(ProductService()),
        ),
        BlocProvider<ListUserCommentBloc>(
          create: (context) => ListUserCommentBloc(UserService()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(CategoryService()),
        ),
        BlocProvider<BannerBloc>(
          create: (context) => BannerBloc(BannerService()),
        ),
        BlocProvider<SearchImageBloc>(
          create: (context) => SearchImageBloc(ImageFeatureService()),
        ),
        BlocProvider<ProductSearchImageBloc>(
          create: (context) => ProductSearchImageBloc(ProductService()),
        ),
        BlocProvider<AllUserBloc>(
          create: (context) => AllUserBloc(UserService()),
        ),
        BlocProvider<ListProductByCategoryBloc>(
          create: (context) => ListProductByCategoryBloc(ProductService()),
        ),
        BlocProvider<ProductFavoriteBloc>(
          create: (context) =>
              ProductFavoriteBloc(UserService(), ProductService()),
        ),
        BlocProvider<SupplierBloc>(
          create: (context) => SupplierBloc(SupplierService()),
        ),
        BlocProvider<ImportReceiptBloc>(
          create: (context) => ImportReceiptBloc(ImportReceiptService()),
        ),
        BlocProvider<AllMessageBloc>(
          create: (context) => AllMessageBloc(ChatService()),
        ),
        BlocProvider<CheckProductCheckoutBloc>(
          create: (context) => CheckProductCheckoutBloc(ProductService()),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('vi'), // Đặt ngôn ngữ chính là tiếng Việt
        supportedLocales: const [
          Locale('vi', ''), // Tiếng Việt
          Locale('en', ''), // Tiếng Anh (dự phòng)
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Noto Sans'),
              bodyMedium: TextStyle(fontFamily: 'Noto Sans'),
              bodySmall: TextStyle(fontFamily: 'Noto Sans'),
              titleLarge: TextStyle(fontFamily: 'Noto Sans'),
              titleMedium: TextStyle(fontFamily: 'Noto Sans'),
              titleSmall: TextStyle(fontFamily: 'Noto Sans'),
              labelLarge: TextStyle(fontFamily: 'Noto Sans'),
              labelMedium: TextStyle(fontFamily: 'Noto Sans'),
              labelSmall: TextStyle(fontFamily: 'Noto Sans'),
              headlineLarge: TextStyle(fontFamily: 'Noto Sans'),
              headlineMedium: TextStyle(fontFamily: 'Noto Sans'),
              headlineSmall: TextStyle(fontFamily: 'Noto Sans'),
              displayLarge: TextStyle(fontFamily: 'Noto Sans'),
              displayMedium: TextStyle(fontFamily: 'Noto Sans'),
              displaySmall: TextStyle(fontFamily: 'Noto Sans'),
            )),
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: const SplashScreen(),
      ),
    );
  }
}
