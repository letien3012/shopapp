import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/address.dart';

class Shop {
  final String? shopId;
  final String userId;
  final String name;
  final List<Address> addresses;
  final String phoneNumber;
  final String email;
  final DateTime submittedAt;
  final String? avatarUrl;
  final String? backgroundImageUrl;
  final String? description;
  final bool isClose;
  final bool isLocked;

  Shop({
    this.shopId,
    required this.userId,
    required this.name,
    required this.addresses,
    required this.phoneNumber,
    required this.email,
    required this.submittedAt,
    this.avatarUrl,
    this.backgroundImageUrl,
    this.description,
    required this.isClose,
    required this.isLocked,
  });

  Shop copyWith({
    String? shopId,
    String? userId,
    String? name,
    List<Address>? addresses,
    String? phoneNumber,
    String? email,
    DateTime? submittedAt,
    String? avatarUrl,
    String? backgroundImageUrl,
    String? description,
    bool? isClose,
    bool? isLocked,
  }) {
    return Shop(
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      submittedAt: submittedAt ?? this.submittedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      description: description ?? this.description,
      isClose: isClose ?? this.isClose,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      shopId: map['shopId'] as String?,
      userId: map['userId'] as String,
      name: map['name'] as String,
      addresses: (map['addresses'] as List<dynamic>)
          .map((e) => Address.fromMap(e as Map<String, dynamic>))
          .toList(),
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      submittedAt: (map['submittedAt'] is Timestamp)
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(map['submittedAt'] as String),
      avatarUrl: map['avatarUrl'] as String?,
      backgroundImageUrl: map['backgroundImageUrl'] as String?,
      description: map['description'] as String?,
      isClose: map['isClose'] as bool,
      isLocked: map['isLocked'] as bool,
    );
  }

  factory Shop.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Shop(
      shopId: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      addresses: (data['addresses'] as List<dynamic>)
          .map((e) => Address.fromMap(e as Map<String, dynamic>))
          .toList(),
      phoneNumber: data['phoneNumber'] as String,
      email: data['email'] as String,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      backgroundImageUrl: data['backgroundImageUrl'] as String?,
      description: data['description'] as String?,
      isClose: data['isClose'] as bool,
      isLocked: data['isLocked'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'name': name,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'phoneNumber': phoneNumber,
      'email': email,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'avatarUrl': avatarUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'description': description,
      'isClose': isClose,
      'isLocked': isLocked,
    };
  }

  String toJson() => json.encode(toMap());

  factory Shop.fromJson(String source) =>
      Shop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Shop(shopId: $shopId, userId: $userId, name: $name, '
        'addresses: $addresses, phoneNumber: $phoneNumber, email: $email, '
        'submittedAt: $submittedAt, avatarUrl: $avatarUrl, '
        'backgroundImageUrl: $backgroundImageUrl, description: $description, '
        'isClose: $isClose, isLocked: $isLocked)';
  }
}
