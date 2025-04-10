import 'package:luanvan/models/permitsion.dart';

class Employee {
  String id;
  String email;
  String phone;
  String userName;
  List<Permission> permissions;

  Employee({
    required this.id,
    required this.email,
    required this.phone,
    required this.userName,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'userName': userName,
      'permissions': permissions.map((p) => p.toMap()).toList(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      userName: map['userName'] as String,
      permissions: List<Permission>.from(
        (map['permissions'] as List).map((p) => Permission.fromMap(p)),
      ),
    );
  }

  Employee copyWith({
    String? id,
    String? email,
    String? phone,
    String? userName,
    List<Permission>? permissions,
  }) {
    return Employee(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userName: userName ?? this.userName,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, email: $email, phone: $phone, userName: $userName, permissions: $permissions)';
  }
}
