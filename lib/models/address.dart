class Address {
  String id;
  late String addressLine;
  String city;
  String district;
  String ward;
  bool isDefault;
  String receiverName;
  String receiverPhone;
  Address({
    required this.id,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.ward,
    required this.isDefault,
    required this.receiverName,
    required this.receiverPhone,
  });

  Address copyWith({
    String? id,
    String? addressLine,
    String? city,
    String? district,
    String? ward,
    bool? isDefault,
    String? receiverName,
    String? receiverPhone,
  }) {
    return Address(
      id: id ?? this.id,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      isDefault: isDefault ?? this.isDefault,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'addressLine': addressLine,
      'city': city,
      'district': district,
      'ward': ward,
      'isDefault': isDefault,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      addressLine: map['addressLine'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'] ?? '',
      isDefault: map['isDefault'] ?? false,
      receiverName: map['receiverName'] ?? '',
      receiverPhone: map['receiverPhone'] ?? '',
    );
  }
}
