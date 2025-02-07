import 'package:flutter/material.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/login/verify_screen.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});
  static String routeName = 'singup_screeen';

  @override
  State<SingupScreen> createState() => _SingupScreenState();
}

class _SingupScreenState extends State<SingupScreen> {
  bool is_check = false;
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
              'Create an account',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            )),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: const Text(
                "Fill your information below of register with your social account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Nhập số điện thoại',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'Nhập số điện thoại của bạn',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300)),
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
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                      color: Colors.brown,
                      alignment: Alignment.center,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(VerifyScreen.routeName);
                },
              ),
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
                    "Sign in",
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
    ));
  }
}
