import 'package:flutter/material.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/login/forgotpw_screen.dart';
import 'package:luanvan/ui/login/singup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static const String routeName = 'signin_screen';

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formLoginKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation cho email hoặc số điện thoại
  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email hoặc số điện thoại';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return 'Email hoặc số điện thoại không hợp lệ';
    }
    return null;
  }

  // Validation cho mật khẩu
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit() {
    if (_formLoginKey.currentState!.validate()) {
      // Logic đăng nhập (gọi API hoặc Firebase ở đây)
      print('Email/Số điện thoại: ${_emailOrPhoneController.text}');
      print('Mật khẩu: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Form(
            key: _formLoginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Số điện thoại hoặc email',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    hintText: 'Email/ số điện thoại',
                    hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                    contentPadding: const EdgeInsets.only(left: 20),
                  ),
                  validator: _validateEmailOrPhone,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    hintText: '**********',
                    hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                    contentPadding: const EdgeInsets.only(left: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(ForgotpwScreen.routeName),
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: Colors.brown,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: GestureDetector(
                    onTap: _submit,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.brown,
                        alignment: Alignment.center,
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Row(
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
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(ImageHelper.facebook_logo),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ClipOval(
                      child: Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(ImageHelper.google_logo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(SingupScreen.routeName),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
