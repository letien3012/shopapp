import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShipSettingScreen extends StatefulWidget {
  const ShipSettingScreen({super.key});
  static String routeName = "ship_setting_screen";

  @override
  State<ShipSettingScreen> createState() => _ShipSettingScreenState();
}

class _ShipSettingScreenState extends State<ShipSettingScreen> {
  bool isFastEnabled = false;
  bool isEconomyEnabled = false;
  bool isExpress = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map;

    isFastEnabled = args['isFastEnabled'];
    isEconomyEnabled = args['isEconomyEnabled'];
    isExpress = args['isExpress'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'isFastEnabled': isFastEnabled,
          'isEconomyEnabled': isEconomyEnabled,
          'isExpress': isExpress
        });
        return false;
      },
      child: Scaffold(
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
                    const SizedBox(height: 10),
                    // Tiết Kiệm
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Tiết Kiệm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển với mức phí cạnh tranh thấp nhất",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isEconomyEnabled,
                            onChanged: (value) {
                              setState(() {
                                isEconomyEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nhanh
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Nhanh",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển chuyên nghiệp, nhanh chóng và đáng tin cậy",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isFastEnabled,
                            onChanged: (value) {
                              setState(() {
                                isFastEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Hỏa tốc
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Hỏa tốc",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Phương thức vận chuyển nhanh nhất",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: isExpress,
                            onChanged: (value) {
                              setState(() {
                                isExpress = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'isFastEnabled': isFastEnabled,
                          'isEconomyEnabled': isEconomyEnabled,
                          'isExpress': isExpress
                        });
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
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Phương thức vận chuyển",
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
      ),
    );
  }
}
