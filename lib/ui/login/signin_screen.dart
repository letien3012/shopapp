import 'package:flutter/material.dart';
import 'package:luanvan/ui/login/forgotpw_screen.dart';
import 'package:luanvan/ui/login/singup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static String routeName = 'singin_screen';
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            const Center(
                child: Text(
              'Sign In',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            )),
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                "Hi! Welcome back, you've been missed",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Số điện thoại hoặc email',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'example@gmail.com',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300)),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Mật khẩu',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: '**********',
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                  suffixIcon: Icon(Icons.remove_red_eye_outlined)),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                        color: Colors.brown,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(ForgotpwScreen.routeName);
                  },
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
                borderRadius: BorderRadius.circular(30),
                child: Container(
                    color: Colors.brown,
                    alignment: Alignment.center,
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              )),
            ),
            const SizedBox(
              height: 80,
            ),
            Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 1,
                width: 50,
                color: Colors.black,
              ),
              const Text(' OR Continue with '),
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
                ClipOval(
                  child: Container(
                    height: 60,
                    width: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ClipOval(
                  child: Container(
                    height: 60,
                    width: 60,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ClipOval(
                  child: Container(
                    height: 60,
                    width: 60,
                    color: Colors.black,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(SingupScreen.routeName);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
