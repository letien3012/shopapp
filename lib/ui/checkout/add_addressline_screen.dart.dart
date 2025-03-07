import 'package:flutter/material.dart';

class AddAddresslineScreen extends StatefulWidget {
  const AddAddresslineScreen({super.key});
  static String routeName = 'add-addressline';

  @override
  State<AddAddresslineScreen> createState() => _AddAddresslineScreenState();
}

class _AddAddresslineScreenState extends State<AddAddresslineScreen> {
  final TextEditingController _addressController = TextEditingController();
  List<String> suggestions = [
    "Số 447, Ấp Bình Quới 1",
    "Nhà Trọ Kim Ngan, Ấp Bình Quới 1",
    "Số 447, Bình Quới 1",
    "Số 447, Ấp Bình Quới 1",
    "Số 447, Ấp Bq 1",
  ];

  @override
  void dispose() {
    _addressController.dispose();
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
                  top: 90,
                  bottom: 90,
                  left: 10,
                  right: 10), // Tăng bottom padding để tránh overlap với nút
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _addressController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "Tên đường, Tòa nhà, Số nhà",
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0, color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0, color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Danh sách gợi ý
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _addressController.text = suggestions[index];
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[500]!,
                                size: 24.0,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  suggestions[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                  // Icon trở về
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
                          "Sửa địa chỉ",
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
          // Nút "Tiếp theo"
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  if (_addressController.text.isNotEmpty) {
                    Navigator.of(context).pop(_addressController.text);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _addressController.text.isNotEmpty
                        ? Colors.brown
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Tiếp theo",
                    style: TextStyle(
                      fontSize: 18,
                      color: _addressController.text.isNotEmpty
                          ? Colors.white
                          : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
