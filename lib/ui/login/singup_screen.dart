import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/home/home_screen.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/login/verify_screen.dart';
import 'package:luanvan/ui/mainscreen.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});
  static String routeName = 'singup_screeen';

  @override
  State<SingupScreen> createState() => _SingupScreenState();
}

class _SingupScreenState extends State<SingupScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool is_check = false;
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamed(MainScreen.routeName);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      }, builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Center(
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Nhập số điện thoại',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _phoneFormKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      hintText: 'Nhập số điện thoại của bạn',
                      hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                      contentPadding: const EdgeInsets.only(left: 20),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    maxLength: 10,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      final RegExp vietnamPhoneRegExp = RegExp(
                        r'^0(3[2-9]|5[6-9]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$',
                      );
                      if (!vietnamPhoneRegExp.hasMatch(value) ||
                          value.length != 10) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: is_check,
                        onChanged: (value) {
                          setState(() {
                            is_check = !is_check;
                          });
                        },
                        activeColor: Colors.brown,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                    ),
                    const Text(
                      'Đồng ý với ',
                      style: TextStyle(fontSize: 17),
                    ),
                    const Text(
                      'Điều khoản và dịch vụ',
                      style: TextStyle(
                          color: Colors.brown,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color:
                            (is_check && _phoneController.value.text.isNotEmpty)
                                ? Colors.brown
                                : Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text(
                          'Tiếp theo',
                          style: TextStyle(
                            fontSize: 20,
                            color: (is_check &&
                                    _phoneController.value.text.isNotEmpty)
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      if (is_check && _phoneController.value.text.isNotEmpty) {
                        if (_phoneFormKey.currentState!.validate()) {
                          context
                              .read<AuthBloc>()
                              .add(SignUpWithPhoneEvent(_phoneController.text));

                          Navigator.of(context)
                              .pushNamed(VerifyScreen.routeName);
                        }
                      } else {
                        if (!is_check) {}
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Container(
                        height: 1,
                        width: 50,
                        color: Colors.black,
                      ),
                      const Text(' Hoặc tiếp tục với '),
                      Container(
                        height: 1,
                        width: 50,
                        color: Colors.black,
                      ),
                    ])),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Facebook Logo
                    GestureDetector(
                      onTap: () {
                        context
                            .read<AuthBloc>()
                            .add(LoginInWithFacebookEvent());
                      },
                      child: ClipOval(
                        child: Container(
                          height: 60,
                          width: 60,
                          child: Image.asset(ImageHelper.facebook_logo),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    //Google Logo
                    GestureDetector(
                      onTap: () {
                        context.read<AuthBloc>().add(LoginWithGoogleEvent());
                      },
                      child: ClipOval(
                        child: Container(
                          height: 60,
                          width: 60,
                          child: Image.asset(ImageHelper.google_logo),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản? "),
                    GestureDetector(
                      child: const Text(
                        "Đăng nhập",
                        style: TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(SigninScreen.routeName);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
