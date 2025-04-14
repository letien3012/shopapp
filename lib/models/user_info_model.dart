import 'dart:convert';
import 'package:luanvan/models/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/viewedProduct.dart';

enum Gender { male, female, other, unknown }

class UserInfoModel {
  String id;
  String? name;
  String? email;
  String? phone;
  String? avataUrl;
  Gender? gender;
  String? date;
  String? userName;
  int role;
  bool isLock;
  List<Address> addresses;
  Timestamp createdAt;
  List<String> favoriteProducts;
  List<ViewedProduct> viewedProducts;

  UserInfoModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.avataUrl,
    this.gender,
    this.date,
    this.userName,
    required this.role,
    this.isLock = false,
    List<Address>? addresses,
    Timestamp? createdAt,
    List<String>? favoriteProducts,
    List<ViewedProduct>? viewedProducts,
  })  : addresses = addresses ?? [],
        createdAt = createdAt ?? Timestamp.now(),
        favoriteProducts = favoriteProducts ?? [],
        viewedProducts = viewedProducts ?? [];

  UserInfoModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avataUrl,
    Gender? gender,
    String? date,
    String? userName,
    int? role,
    bool? isLock,
    List<Address>? addresses,
    Timestamp? createdAt,
    List<String>? favoriteProducts,
    List<ViewedProduct>? viewedProducts,
  }) {
    return UserInfoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avataUrl: avataUrl ?? this.avataUrl,
      gender: gender ?? this.gender,
      date: date ?? this.date,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      isLock: isLock ?? this.isLock,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      viewedProducts: viewedProducts ?? this.viewedProducts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avataUrl': avataUrl,
      'gender': gender?.toString().split('.').last,
      'date': date,
      'userName': userName,
      'role': role,
      'isLock': isLock,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'createdAt': createdAt,
      'favoriteProducts': favoriteProducts,
      'viewedProducts':
          viewedProducts.map((viewedProduct) => viewedProduct.toMap()).toList(),
    };
  }

  factory UserInfoModel.fromMap(Map<String, dynamic> map) {
    return UserInfoModel(
      id: map['id'] as String,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avataUrl: map['avataUrl'] ?? '',
      gender: map['gender'] != null
          ? Gender.values.firstWhere(
              (g) => g.toString().split('.').last == map['gender'],
              orElse: () => Gender.unknown,
            )
          : null,
      date: map['date'],
      userName: map['userName'],
      role: map['role'] as int? ?? 0,
      isLock: map['isLock'] as bool? ?? false,
      addresses: map['addresses'] != null
          ? List<Address>.from(
              (map['addresses'] as List).map((x) => Address.fromMap(x)))
          : [],
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      favoriteProducts: map['favoriteProducts'] != null
          ? List<String>.from(map['favoriteProducts'])
          : [],
      viewedProducts: map['viewedProducts'] != null
          ? List<ViewedProduct>.from((map['viewedProducts'] as List)
              .map((x) => ViewedProduct.fromMap(x)))
          : [],
    );
  }

  factory UserInfoModel.fromFirestore(Map<String, dynamic> data) {
    return UserInfoModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avataUrl: data['avataUrl'] ?? '',
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (g) => g.toString().split('.').last == data['gender'],
              orElse: () => Gender.unknown,
            )
          : Gender.unknown,
      date: data['date'] ?? '',
      userName: data['userName'] ?? '',
      role: data['role'] ?? 0,
      isLock: data['isLock'] ?? false,
      addresses: data['addresses'] != null
          ? List<Address>.from(
              (data['addresses'] as List).map((x) => Address.fromMap(x)))
          : [],
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      favoriteProducts: data['favoriteProducts'] != null
          ? List<String>.from(data['favoriteProducts'])
          : [],
      viewedProducts: data['viewedProducts'] != null
          ? List<ViewedProduct>.from((data['viewedProducts'] as List)
              .map((x) => ViewedProduct.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromJson(String source) =>
      UserInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, avataUrl: $avataUrl, gender: $gender, date: $date, userName: $userName, role: $role, isLock: $isLock, addresses: $addresses, createdAt: $createdAt, favoriteProducts: $favoriteProducts, viewedProducts: $viewedProducts)';
  }
}
