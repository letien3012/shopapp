import 'package:flutter/material.dart';

class ForgotpwScreen extends StatefulWidget {
  const ForgotpwScreen({super.key});
  static String routeName = 'forgotpw_screen';
  @override
  State<ForgotpwScreen> createState() => _ForgotpwScreenState();
}

class _ForgotpwScreenState extends State<ForgotpwScreen> {
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
              'Quên mật khẩu',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            )),
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
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'Nhập số điện thoại đã đăng ký',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300)),
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Text(
                  '* ',
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  "Mã xác nhận sẽ được gửi qua số điện thoại",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
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
                      'Nhận mã',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              )),
            ),
          ],
        ),
      ),
    ));
  }
}
