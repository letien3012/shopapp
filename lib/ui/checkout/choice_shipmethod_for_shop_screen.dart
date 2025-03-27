import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/models/shipping_method.dart';

class ChoiceShipmethodForShopScreen extends StatefulWidget {
  static const String routeName = 'choice_ship_for_shop_screen';

  const ChoiceShipmethodForShopScreen({
    super.key,
  });

  @override
  State<ChoiceShipmethodForShopScreen> createState() =>
      _ChoiceShipmethodForShopScreenState();
}

class _ChoiceShipmethodForShopScreenState
    extends State<ChoiceShipmethodForShopScreen> {
  ShippingMethod? selectedMethod;
  String shopId = '';
  List<ShippingMethod> shippingMethods = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      setState(() {
        shopId = arg['shopId'];
        shippingMethods = arg['shipMethod'];
        selectedMethod = arg['selectedMethod'];
      });
    });
    super.initState();
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainScrollView(context),
          _buildAppBar(context),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child:
                    const Icon(Icons.arrow_back, color: Colors.brown, size: 30),
              ),
            ),
            const SizedBox(width: 10),
            const Text("Phương thức vận chuyển",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[200],
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        padding: const EdgeInsets.only(top: 80, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShippingMethodsSection(),
          ],
        ),
      ),
    );
  }

  // Shipping Methods Section
  Widget _buildShippingMethodsSection() {
    if (shippingMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Text(
              "Không có phương thức vận chuyển nào",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tất cả phương thức vận chuyển",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ...shippingMethods.map((entry) {
            final methodData = entry;
            final name = methodData.name;
            final price = (methodData.cost as num?)?.toDouble() ?? 0.0;
            DateTime now = DateTime.now();
            int estimatedDays = entry.estimatedDeliveryDays;
            DateTime estimatedDate = now.add(Duration(days: estimatedDays));

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMethod = methodData;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                  "Nhận hàng từ ${DateTime.now().day} tháng ${DateTime.now().month} - ${estimatedDate.day} tháng ${estimatedDate.month}",
                                  style: TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "đ${formatPrice(price)}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            if (selectedMethod!.name == methodData.name)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 0.3,
                  color: Colors.grey,
                )
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // Bottom Bar
  Widget _buildBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 60,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context, selectedMethod);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "Xác nhận",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
