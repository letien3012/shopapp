import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/ui/checkout/pick_location.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});
  static String routeName = "add_location_screen";
  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusPhone = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool isAddDefault = false;
  @override
  void initState() {
    super.initState();
    _focusName.addListener(() {
      setState(() {});
    });
    _focusPhone.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusName.dispose();
    _focusPhone.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              padding: const EdgeInsets.only(
                  top: 90, bottom: 20, left: 10, right: 10),
              child: Column(
                children: [
                  // Địa chỉ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Địa chỉ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextFormField(
                          focusNode: _focusName,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            labelStyle: const TextStyle(fontSize: 13),
                            floatingLabelStyle: const TextStyle(fontSize: 16),
                            suffixIcon: _focusName.hasFocus
                                ? const Icon(
                                    Icons.cancel,
                                    size: 18,
                                  )
                                : null,
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0.5, color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                        ),
                        TextFormField(
                          focusNode: _focusPhone,
                          keyboardType: const TextInputType.numberWithOptions(),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            labelStyle: const TextStyle(fontSize: 13),
                            floatingLabelStyle: const TextStyle(fontSize: 16),
                            suffixIcon: _focusPhone.hasFocus
                                ? const Icon(
                                    Icons.cancel,
                                    size: 18,
                                  )
                                : null,
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0.5, color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(PickLocation.routeName);
                          },
                          child: Container(
                            height: 60,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(PickLocation.routeName);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            height: 60,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Tên đường, Tòa nhà, Số nhà",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Đặt làm địa chỉ mặc định"),
                              CupertinoSwitch(
                                value: isAddDefault,
                                onChanged: (value) {
                                  setState(() {
                                    isAddDefault = !isAddDefault;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Appbar
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  //Icon trở về
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Địa chỉ mới",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
