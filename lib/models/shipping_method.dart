class ShippingMethod {
  final String name;
  final double cost;
  final int estimatedDeliveryDays;
  bool isEnabled;

  ShippingMethod({
    required this.name,
    required this.cost,
    required this.estimatedDeliveryDays,
    this.isEnabled = false,
  });

  ShippingMethod copyWith({
    String? name,
    double? cost,
    int? estimatedDeliveryDays,
    bool? isEnabled,
  }) {
    return ShippingMethod(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      estimatedDeliveryDays:
          estimatedDeliveryDays ?? this.estimatedDeliveryDays,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'isEnabled': isEnabled,
    };
  }

  factory ShippingMethod.fromMap(Map<String, dynamic> map) {
    return ShippingMethod(
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
      estimatedDeliveryDays: map['estimatedDeliveryDays'] as int,
      isEnabled: map['isEnabled'] as bool? ?? false,
    );
  }

  static final List<ShippingMethod> defaultMethods = [
    ShippingMethod(
        name: "Tiết kiệm",
        cost: 1.5,
        estimatedDeliveryDays: 5,
        isEnabled: false),
    ShippingMethod(
        name: "Nhanh", cost: 3.0, estimatedDeliveryDays: 3, isEnabled: false),
    ShippingMethod(
        name: "Hỏa tốc", cost: 5.0, estimatedDeliveryDays: 1, isEnabled: false),
  ];

  static ShippingMethod getMethodByName(String name) {
    return defaultMethods.firstWhere(
      (method) => method.name == name,
      orElse: () => defaultMethods[0],
    );
  }
}
