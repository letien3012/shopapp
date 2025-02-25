import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luanvan/ui/mainscreen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static String routeName = 'verify_screen';
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.arrow_back))),
            ),
            const SizedBox(
              height: 30,
            ),
            const Center(
                child: Text(
              'Mã xác nhận',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            )),
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                "Vui lòng nhập mã được gửi đến",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
            const Center(
              child: Text(
                'example@gmail.com',
                style:
                    TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Nhập mã xác minh',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Form(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin1) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black))),
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin2) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black))),
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin3) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black))),
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin4) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black))),
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin5) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.black))),
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    onSaved: (pin6) {},
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.brown))),
                  ),
                )
              ],
            )),
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
                        'Xác nhận',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(MainScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
