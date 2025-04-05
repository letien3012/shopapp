import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/mainscreen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static String routeName = 'verify_screen';
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String email = '';
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getSmsCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void startEmailVerificationCheck() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        print("✅ Email đã xác minh!");
        context.read<AuthBloc>().add(VerifyEmailEvent());
        timer.cancel(); // Dừng kiểm tra
      } else {
        print("⏳ Chờ người dùng xác minh email...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    email = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Xác thực Email'),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthEmailVerified) {}
                if (state is AuthAuthenticated) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is AuthEmailVerified) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Nhập mật khẩu mới',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                hintText: 'Nhập mật khẩu mới',
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w300),
                                contentPadding: const EdgeInsets.only(left: 20),
                                errorStyle: const TextStyle(color: Colors.red),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (value.length < 8) {
                                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Mật khẩu phải chứa ít nhất một chữ hoa (A-Z)';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Mật khẩu phải chứa ít nhất một chữ thường (a-z)';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Mật khẩu phải chứa ít nhất một số (0-9)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                hintText: 'Nhập lại mật khẩu mới',
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w300),
                                contentPadding: const EdgeInsets.only(left: 20),
                                errorStyle: const TextStyle(color: Colors.red),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmText =
                                          !_obscureConfirmText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập lại mật khẩu';
                                }
                                if (value != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: GestureDetector(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Colors.brown,
                              alignment: Alignment.center,
                              child: const Text(
                                'Xác nhận',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    SignUpWithEmailAndPasswordEvent(
                                      email,
                                      _passwordController.text,
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
                if (state is AuthEmailVerificationSent) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                                'Vui lòng kiểm tra thông báo được gửi đến email'),
                            const SizedBox(height: 10),
                            Text(email),
                            const SizedBox(height: 10),
                            Image.asset(
                              ImageHelper.smartphone_with_speech_bubble,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 20),
                            StreamBuilder<int>(
                              stream: Stream.periodic(
                                const Duration(seconds: 1),
                                (i) => 60 - i - 1,
                              ).take(60),
                              builder: (context, snapshot) {
                                final seconds = snapshot.data ?? 60;
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        (seconds > 0)
                                            ? Row(
                                                children: [
                                                  Text(
                                                    'Nếu chưa nhận được vui lòng chờ trong',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' ${seconds}s ',
                                                    style: TextStyle(
                                                      color: Colors.brown,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    'để gửi lại',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : (seconds == 0)
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        'Bạn vẫn chưa nhận được email xác thực? ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          context
                                                              .read<AuthBloc>()
                                                              .add(
                                                                  SendEmailVerificationEvent(
                                                                      email));
                                                        },
                                                        child: Text(
                                                          'Gửi lại',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox.shrink()
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Text(
                          'Để tăng cường bảo mật cho tài khoản của bạn, hãy xác minh thông tin bằng cách sau'),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<AuthBloc>()
                              .add(SendEmailVerificationEvent(email));
                          startEmailVerificationCheck();
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.link, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Xác minh bằng liên kết Email',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }
}
