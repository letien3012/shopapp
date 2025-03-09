import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/address.dart';

class SellerRegistration {
  final String? shopId; // Đổi từ registrationId thành shopId
  final String userId;
  final String name;
  final Address address;
  final String phoneNumber;
  final String email;
  final DateTime submittedAt;

  SellerRegistration({
    this.shopId, // Cập nhật tên trong constructor
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.submittedAt,
  });

  SellerRegistration copyWith({
    String? shopId, // Cập nhật tên trong copyWith
    String? userId,
    String? name,
    Address? address,
    String? phoneNumber,
    String? email,
    DateTime? submittedAt,
  }) {
    return SellerRegistration(
      shopId: shopId ?? this.shopId, // Cập nhật tên
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  factory SellerRegistration.fromMap(Map<String, dynamic> map) {
    return SellerRegistration(
      shopId: map['shopId'] as String?, // Cập nhật tên trong fromMap
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: Address.fromMap(map['address'] as Map<String, dynamic>),
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      submittedAt: (map['submittedAt'] is Timestamp)
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(map['submittedAt'] as String),
    );
  }

  factory SellerRegistration.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SellerRegistration(
      shopId: doc.id, // Cập nhật tên trong fromFirestore
      userId: data['userId'] as String,
      name: data['name'] as String,
      address: Address.fromMap(data['address'] as Map<String, dynamic>),
      phoneNumber: data['phoneNumber'] as String,
      email: data['email'] as String,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId, // Cập nhật tên trong toMap
      'userId': userId,
      'name': name,
      'address': address.toMap(),
      'phoneNumber': phoneNumber,
      'email': email,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  String toJson() => json.encode(toMap());

  factory SellerRegistration.fromJson(String source) =>
      SellerRegistration.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SellerRegistration(shopId: $shopId, userId: $userId, name: $name, '
        'address: $address, phoneNumber: $phoneNumber, email: $email, submittedAt: $submittedAt)';
  }
}
