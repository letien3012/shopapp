import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/address.dart';

class Shop {
  final String? shopId;
  final String userId;
  final String name;
  final Address address;
  final String phoneNumber;
  final String email;
  final DateTime submittedAt;
  final String? avatarUrl;
  final bool isClose;
  final bool isLocked;

  Shop({
    this.shopId,
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.submittedAt,
    this.avatarUrl,
    required this.isClose,
    required this.isLocked,
  });

  Shop copyWith({
    String? shopId,
    String? userId,
    String? name,
    Address? address,
    String? phoneNumber,
    String? email,
    DateTime? submittedAt,
    String? avatarUrl,
    bool? isClose,
    bool? isLocked,
  }) {
    return Shop(
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      submittedAt: submittedAt ?? this.submittedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isClose: isClose ?? this.isClose,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      shopId: map['shopId'] as String?,
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: Address.fromMap(map['address'] as Map<String, dynamic>),
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      submittedAt: (map['submittedAt'] is Timestamp)
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(map['submittedAt'] as String),
      avatarUrl: map['avatarUrl'] as String?,
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
      address: Address.fromMap(data['address'] as Map<String, dynamic>),
      phoneNumber: data['phoneNumber'] as String,
      email: data['email'] as String,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      isClose: data['isClose'] as bool,
      isLocked: data['isLocked'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'name': name,
      'address': address.toMap(),
      'phoneNumber': phoneNumber,
      'email': email,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'avatarUrl': avatarUrl,
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
        'address: $address, phoneNumber: $phoneNumber, email: $email, '
        'submittedAt: $submittedAt, avatarUrl: $avatarUrl, '
        'isClose: $isClose, isLocked: $isLocked)';
  }
}
