import 'dart:convert';
import 'package:luanvan/models/address.dart';

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
  List<Address> addresses;

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
    List<Address>? addresses,
  }) : addresses = addresses ?? [];

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
    List<Address>? addresses,
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
      addresses: addresses ?? this.addresses,
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
      'addresses': addresses.map((address) => address.toMap()).toList(),
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
      addresses: map['addresses'] != null
          ? List<Address>.from(
              (map['addresses'] as List).map((x) => Address.fromMap(x)))
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
      addresses: data['addresses'] != null
          ? List<Address>.from(
              (data['addresses'] as List).map((x) => Address.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromJson(String source) =>
      UserInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, avataUrl: $avataUrl, gender: $gender, date: $date, userName: $userName, role: $role, addresses: $addresses)';
  }
}
