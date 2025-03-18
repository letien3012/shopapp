import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';

class DeliveryCostScreen extends StatefulWidget {
  const DeliveryCostScreen({super.key});
  static String routeName = 'delivery_cost';

  @override
  State<DeliveryCostScreen> createState() => _DeliveryCostScreenState();
}

class _DeliveryCostScreenState extends State<DeliveryCostScreen> {
  late UserInfoModel user;
  List<ProductOption> _productOptions = [];
  Product product = Product(
    id: '',
    name: '',
    quantitySold: 0,
    description: '',
    averageRating: 0,
    variants: [
      ProductVariant(label: "Màu sắc", options: []),
    ],
    shopId: '',
    isViolated: false,
    isHidden: false,
    hasVariantImages: false,
    hasWeightVariant: false,
    shippingMethods: [],
  );
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _shipController = TextEditingController();
  bool isFastEnabledProduct = false;
  bool isEconomyEnabledProduct = false;
  bool isExpressProduct = false;
  bool hasWeightVariant = false;

  Map<int, TextEditingController> _weightControllers = {};

  @override
  void initState() {
    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      user = args['user'] as UserInfoModel;
      product = args['product'] as Product;
      product.variants.forEach(
        (element) {
          _productOptions.addAll(element.options);
        },
      );
      hasWeightVariant = product.hasWeightVariant;
      isFastEnabledProduct = product.shippingMethods[0].isEnabled;
      isEconomyEnabledProduct = product.shippingMethods[1].isEnabled;
      isExpressProduct = product.shippingMethods[2].isEnabled;
      context.read<ShopBloc>().add(FetchShopEvent(user.id));
    });
    super.initState();
  }

  @override
  void dispose() {
    _weight.dispose();
    _shipController.dispose();
    _weightControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (hasWeightVariant) {
        int i = 0;
        while (i < _productOptions.length) {
          product.variants.forEach(
            (element) {
              for (int j = 0; j < element.options.length; j++) {
                element.options[j] = _productOptions[i].copyWith(
                    weight: double.parse(_weightControllers[i]!.text));
                i++;
              }
            },
          );
        }
      } else {
        product.weight = double.parse(_weight.text);
      }
      product.hasWeightVariant = hasWeightVariant;
      Navigator.of(context).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, shopState) {
          if (shopState is ShopLoading) {
            return _buildLoading();
          } else if (shopState is ShopLoaded) {
            _weightControllers = {
              for (int i = 0; i < _productOptions.length; i++)
                i: TextEditingController(
                  text: _productOptions[i].weight?.toString() ?? '',
                ),
            };
            return _buildShopContent(context, shopState.shop);
          } else if (shopState is ShopError) {
            return _buildError(shopState.message);
          }
          return _buildInitializing();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildShopContent(BuildContext context, Shop shop) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.only(top: 90, bottom: 80),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hasWeightVariant
                      ? Container()
                      : Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Cân nặng(g) ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _weight,
                                maxLength: 5,
                                decoration: const InputDecoration(
                                  hintText: "Nhập cân nặng",
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (!hasWeightVariant &&
                                      (value == null || value.isEmpty)) {
                                    return "Vui lòng nhập cân nặng";
                                  }
                                  final weight =
                                      double.tryParse(value ?? '0') ?? 0;

                                  if (!hasWeightVariant && weight <= 0) {
                                    return "Cân nặng phải lớn hơn 0";
                                  }
                                  if (!hasWeightVariant && weight > 30000) {
                                    return "Cân nặng tối đa 30,000g";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Thiết lập cân nặng cho từng phân loại. Khi bật tính năng này, tất cả phân loại phải có cân nặng",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        CupertinoSwitch(
                          value: hasWeightVariant,
                          onChanged: (value) {
                            setState(() {
                              hasWeightVariant = value;
                              if (value) {
                                if (product.getTotalOptionsCount() <= 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Vui lòng thêm nhiều hơn 2 phân loại hàng"),
                                      backgroundColor: Colors.black,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  hasWeightVariant = false;
                                } else {
                                  _weightControllers = {
                                    for (int i = 0;
                                        i < _productOptions.length;
                                        i++)
                                      i: TextEditingController(
                                        text: _productOptions[i]
                                                .weight
                                                ?.toString() ??
                                            '',
                                      ),
                                  };
                                }
                              } else {
                                _weightControllers.values.forEach(
                                    (controller) => controller.dispose());
                                _weightControllers.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (hasWeightVariant &&
                      product.getTotalOptionsCount() > 1) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _productOptions.asMap().entries.map((entry) {
                        int index = entry.key;
                        ProductOption option = entry.value;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    option.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    maxLength: 5,
                                    controller: _weightControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: "Nhập cân nặng (g)",
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      if (hasWeightVariant &&
                                          (value == null || value.isEmpty)) {
                                        return "Vui lòng nhập cân nặng";
                                      }
                                      final weight =
                                          double.tryParse(value ?? '0') ?? 0;
                                      if (hasWeightVariant && weight <= 0) {
                                        return "Cân nặng phải lớn hơn 0g";
                                      }
                                      if (hasWeightVariant && weight > 30000) {
                                        return "Cân nặng tối đa 30,000g";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  shop.shippingMethods[0].isEnabled
                      ? Container(
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
                                    const Text(
                                      "Tiết Kiệm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Tiết kiệm ()",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isEconomyEnabledProduct,
                                onChanged: (value) {
                                  setState(() {
                                    isEconomyEnabledProduct = value;
                                    product.shippingMethods[0].isEnabled =
                                        value;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  shop.shippingMethods[0].isEnabled
                      ? const SizedBox(height: 10)
                      : Container(),
                  shop.shippingMethods[1].isEnabled
                      ? Container(
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
                                    const Text(
                                      "Nhanh",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Nhanh ()",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isFastEnabledProduct,
                                onChanged: (value) {
                                  setState(() {
                                    isFastEnabledProduct = value;
                                    product.shippingMethods[1].isEnabled =
                                        value;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  shop.shippingMethods[1].isEnabled
                      ? const SizedBox(height: 10)
                      : Container(),
                  shop.shippingMethods[2].isEnabled
                      ? Container(
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
                                    const Text(
                                      "Hỏa tốc",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Hỏa tốc ()",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isExpressProduct,
                                onChanged: (value) {
                                  setState(() {
                                    isExpressProduct = value;
                                    product.shippingMethods[2].isEnabled =
                                        value;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 90,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding:
                const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.brown,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  height: 40,
                  child: Text(
                    "Phí vận chuyển",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lưu",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
