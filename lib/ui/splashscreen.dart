import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:luanvan/blocs/allmessage/all_message_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/ui/admin_mainscreen.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String routeName = 'splash_screen';
  @override
  State<SplashScreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashScreen> {
  bool isAdmin = false;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        context.read<AuthBloc>().add(CheckLoginStatus());

        await context.read<AuthBloc>().stream.firstWhere((state) =>
            state is AdminAuthenticated ||
            state is AuthAuthenticated ||
            state is AuthUnauthenticated);
        final authState = context.read<AuthBloc>().state;
        if (authState is AdminAuthenticated) {
          setState(() {
            isAdmin = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AdminAuthenticated) {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminMainScreen(),
                ));
          }
          if (state is AuthAuthenticated || state is AuthUnauthenticated) {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ));
          }
        },
        child: Container(
          color: Colors.white,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              ImageHelper.logo,
            ),
          ),
        ));
  }
}
