import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/di.dart';
import 'package:luanvan/routes.dart';
import 'package:luanvan/services/auth_service.dart';
import 'package:luanvan/services/user_service.dart';
import 'package:luanvan/ui/splashscreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        )
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
