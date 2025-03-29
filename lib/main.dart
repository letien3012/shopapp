import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat_room/chat_room_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_user/list_user_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_bloc.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/user_chat/user_chat_bloc.dart';
import 'package:luanvan/di.dart';
import 'package:luanvan/routes.dart';
import 'package:luanvan/services/auth_service.dart';
import 'package:luanvan/services/cart_service.dart';
import 'package:luanvan/services/chat_service.dart';
import 'package:luanvan/services/order_service.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/services/shop_service.dart';
import 'package:luanvan/services/user_service.dart';
import 'package:luanvan/ui/splashscreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ui.PlatformDispatcher.instance.onMetricsChanged = () {
    final double refreshRate =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    print("Device refresh rate: $refreshRate Hz");
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
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(create: (_) => ProductBloc()..add(FetchProductsEvent())),
        // BlocProvider(create: (_) => CartBloc()),
        // BlocProvider(create: (_) => MessageBloc()),
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
        ),
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: SplashScreen(),
        // initialRoute: '/home',
        // routes: {
        //   '/home': (_) => const HomeScreen(),
        //   '/product_detail': (_) => const ProductDetailScreen(),
        //   '/profile': (_) => const ProfileScreen(),
        // },
      ),
    );
  }
}
