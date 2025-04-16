import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_calculator.dart';
import 'package:luanvan/models/shop.dart';
import 'package:intl/intl.dart';

class DeliveryCostScreen extends StatefulWidget {
  const DeliveryCostScreen({super.key});
  static String routeName = 'delivery_cost';

  @override
  State<DeliveryCostScreen> createState() => _DeliveryCostScreenState();
}

class _DeliveryCostScreenState extends State<DeliveryCostScreen> {
  Product product = Product(
      id: '',
      name: '',
      quantitySold: 0,
      description: '',
      averageRating: 0,
      variants: [],
      shopId: '',
      isHidden: false,
      hasVariantImages: false,
      shippingMethods: []);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _shipController = TextEditingController();
  bool isFastEnabledProduct = false;
  bool isEconomyEnabledProduct = false;
  bool isExpressProduct = false;
  bool hasWeightVariant = false;
  List<String> price = ['', '', ''];
  Map<int, TextEditingController> _weightControllers = {};
  final NumberFormat _numberFormat = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      product = args['product'] as Product;
      hasWeightVariant = product.hasWeightVariant;

      // Khởi tạo trọng lượng từ optionInfos
      if (hasWeightVariant && product.optionInfos.isNotEmpty) {
        _weightControllers = {
          for (int i = 0; i < product.optionInfos.length; i++)
            i: TextEditingController(
              text: product.optionInfos[i].weight?.toString() ?? '0',
            ),
        };
      } else {
        _weight.text = product.weight?.toString() ?? '0';
      }

      isEconomyEnabledProduct = product.shippingMethods[0].isEnabled;
      isFastEnabledProduct = product.shippingMethods[1].isEnabled;
      isExpressProduct = product.shippingMethods[2].isEnabled;

      // Tính giá ban đầu nếu phương thức vận chuyển đã được bật
      if (hasWeightVariant) {
        if (isEconomyEnabledProduct) _updateEconomyPrice();
        if (isFastEnabledProduct) _updateFastPrice();
        if (isExpressProduct) _updateExpressPrice();
      } else {
        if (isEconomyEnabledProduct) {
          price[0] =
              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: double.parse(_weight.text)))}";
        }
        if (isFastEnabledProduct) {
          price[1] =
              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: double.parse(_weight.text)))}";
        }
        if (isExpressProduct) {
          price[2] =
              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: double.parse(_weight.text)))}";
        }
      }
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ShopBloc>().add(FetchShopEvent(authState.user.uid));
      }
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

  double getMaxWeight() {
    if (product.optionInfos.isEmpty) return 0.0;
    List<double> weights = product.optionInfos
        .map((option) => option.weight ?? 0.0)
        .where((weight) => weight > 0.0)
        .toList();
    if (weights.isEmpty) return 0.0;
    return weights.reduce((a, b) => a > b ? a : b);
  }

  double getMinWeight() {
    if (product.optionInfos.isEmpty) return 0.0;
    List<double> weights = product.optionInfos
        .map((option) => option.weight ?? 0.0)
        .where((weight) => weight > 0.0)
        .toList();
    if (weights.isEmpty) return 0.0;
    return weights.reduce((a, b) => a < b ? a : b);
  }

  String formatPrice(double value) {
    return "${_numberFormat.format(value)} VND";
  }

  void _updateEconomyPrice() {
    if (getMinWeight() ~/ 1000 != getMaxWeight() ~/ 1000) {
      price[0] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: getMinWeight()))} - ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: getMaxWeight()))}";
    } else {
      price[0] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: getMinWeight()))}";
    }
  }

  void _updateFastPrice() {
    if (getMinWeight() ~/ 1000 != getMaxWeight() ~/ 1000) {
      price[1] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: getMinWeight()))} - ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: getMaxWeight()))}";
    } else {
      price[1] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: getMinWeight()))}";
    }
  }

  void _updateExpressPrice() {
    if (getMinWeight() ~/ 1000 != getMaxWeight() ~/ 1000) {
      price[2] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: getMinWeight()))} - ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: getMaxWeight()))}";
    } else {
      price[2] =
          "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: getMinWeight()))}";
    }
  }

  void _updateShippingPrices() {
    if (isEconomyEnabledProduct) _updateEconomyPrice();
    if (isFastEnabledProduct) _updateFastPrice();
    if (isExpressProduct) _updateExpressPrice();
  }

  Future<void> _submitForm() async {
    if (!(isEconomyEnabledProduct ||
        isFastEnabledProduct ||
        isExpressProduct)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Vui lòng chọn kích hoạt ít nhất 1 phương thức vận chuyển cho sản phẩm")),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (hasWeightVariant) {
        for (int i = 0; i < product.optionInfos.length; i++) {
          double weight = double.parse(_weightControllers[i]!.text);
          product.optionInfos[i] =
              product.optionInfos[i].copyWith(weight: weight);
        }
      } else {
        double weight = double.parse(_weight.text);
        product.weight = weight;
        if (product.optionInfos.isNotEmpty) {
          product.optionInfos = product.optionInfos
              .map((info) => info.copyWith(weight: weight))
              .toList();
        }
      }
      product.hasWeightVariant = hasWeightVariant;
      product.shippingMethods[0].isEnabled = isEconomyEnabledProduct;
      product.shippingMethods[1].isEnabled = isFastEnabledProduct;
      product.shippingMethods[2].isEnabled = isExpressProduct;
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
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
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
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Nhập cân nặng",
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (_formKey.currentState!.validate()) {
                                      double weight =
                                          double.tryParse(value) ?? 0;
                                      product.weight = weight;
                                      if (product.optionInfos.isNotEmpty) {
                                        product.optionInfos = product
                                            .optionInfos
                                            .map((info) =>
                                                info.copyWith(weight: weight))
                                            .toList();
                                      }
                                      if (isEconomyEnabledProduct) {
                                        price[0] =
                                            "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: weight))}";
                                      }
                                      if (isFastEnabledProduct) {
                                        price[1] =
                                            "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: weight))}";
                                      }
                                      if (isExpressProduct) {
                                        price[2] =
                                            "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: weight))}";
                                      }
                                    }
                                  });
                                },
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
                                        i < product.optionInfos.length;
                                        i++)
                                      i: TextEditingController(
                                        text: product.optionInfos[i].weight
                                                ?.toString() ??
                                            '0',
                                      ),
                                  };
                                  _updateShippingPrices();
                                }
                              } else {
                                _weightControllers.values.forEach(
                                    (controller) => controller.dispose());
                                _weightControllers.clear();
                                if (isEconomyEnabledProduct) {
                                  price[0] =
                                      "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: double.parse(_weight.text)))}";
                                }
                                if (isFastEnabledProduct) {
                                  price[1] =
                                      "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: double.parse(_weight.text)))}";
                                }
                                if (isExpressProduct) {
                                  price[2] =
                                      "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: double.parse(_weight.text)))}";
                                }
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
                      children: List.generate(
                        product.optionInfos.length,
                        (index) {
                          String optionName = '';
                          if (product.variants.length == 1) {
                            optionName =
                                product.variants[0].options[index].name;
                          } else if (product.variants.length == 2) {
                            int secondVariantOptionsLength =
                                product.variants[1].options.length;
                            int i = index % secondVariantOptionsLength;
                            int j = index ~/ secondVariantOptionsLength;
                            optionName =
                                "${product.variants[0].options[j].name}  ${product.variants[1].options[i].name}";
                          }

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
                                      optionName,
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
                                      onChanged: (value) {
                                        setState(() {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            double weight =
                                                double.tryParse(value) ?? 0;
                                            product.optionInfos[index] = product
                                                .optionInfos[index]
                                                .copyWith(weight: weight);
                                            _updateShippingPrices();
                                          }
                                        });
                                      },
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
                                        if (hasWeightVariant &&
                                            weight > 30000) {
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
                        },
                      ),
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
                                      isEconomyEnabledProduct ? price[0] : '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isEconomyEnabledProduct,
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      if (_formKey.currentState!.validate()) {
                                        isEconomyEnabledProduct = value;
                                        if (hasWeightVariant) {
                                          _updateEconomyPrice();
                                        } else {
                                          price[0] =
                                              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Tiết kiệm', weight: double.parse(_weight.text)))}";
                                        }
                                      }
                                    } else {
                                      isEconomyEnabledProduct = value;
                                      price[0] = '';
                                    }
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
                                      isFastEnabledProduct ? price[1] : '',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isFastEnabledProduct,
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      if (_formKey.currentState!.validate()) {
                                        isFastEnabledProduct = value;
                                        if (hasWeightVariant) {
                                          _updateFastPrice();
                                        } else {
                                          price[1] =
                                              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Nhanh', weight: double.parse(_weight.text)))}";
                                        }
                                      }
                                    } else {
                                      isFastEnabledProduct = value;
                                      price[1] = '';
                                    }
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
                                      isExpressProduct ? price[2] : '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: isExpressProduct,
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      if (_formKey.currentState!.validate()) {
                                        isExpressProduct = value;
                                        if (hasWeightVariant) {
                                          _updateExpressPrice();
                                        } else {
                                          price[2] =
                                              "~ ${formatPrice(ShippingCalculator.calculateShippingCost(methodName: 'Hỏa tốc', weight: double.parse(_weight.text)))}";
                                        }
                                      }
                                    } else {
                                      isExpressProduct = value;
                                      price[2] = '';
                                    }
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
