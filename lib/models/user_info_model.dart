import 'dart:convert';
import 'package:luanvan/blocs/auth/auth_state.dart';

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

  UserInfoModel({
    required this.id, // Chỉ id là required
    this.name,
    this.email,
    this.phone,
    this.avataUrl,
    this.gender,
    this.date,
    this.userName,
  });

  UserInfoModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avataUrl,
    Gender? gender,
    String? date,
    String? userName,
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
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avataUrl': avataUrl,
      'gender': gender?.toString().split('.').last,
      'date': date,
      'userName': userName,
    };
  }

  factory UserInfoModel.fromMap(Map<String, dynamic> map) {
    return UserInfoModel(
      id: map['id'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      avataUrl: map['avataUrl'] != null ? map['avataUrl'] as String : null,
      gender: map['gender'] != null
          ? Gender.values.firstWhere(
              (g) => g.toString().split('.').last == map['gender'],
              orElse: () => Gender.unknown, // Giá trị mặc định nếu không khớp
            )
          : null,
      date: map['date'] != null ? map['date'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
    );
  }

  factory UserInfoModel.fromAuthState(AuthAuthenticated state) {
    final user = state.user;
    return UserInfoModel(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      phone: user.phoneNumber,
      avataUrl: user.photoURL,
      gender: Gender.unknown,
      date: null,
      userName: null,
    );
  }

  factory UserInfoModel.fromFirestore(Map<String, dynamic> data) {
    return UserInfoModel(
      id: data['id'] ?? '',
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      avataUrl: data['avataUrl'],
      date: data['date'],
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (g) => g.toString().split('.').last == data['gender'],
              orElse: () => Gender.unknown,
            )
          : Gender.unknown,
      userName: data['userName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromJson(String source) =>
      UserInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, avataUrl: $avataUrl, gender: $gender, date: $date, userName: $userName)';
  }
}
