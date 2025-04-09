import 'package:cloud_firestore/cloud_firestore.dart';

enum SupplierStatus {
  active,
  inactive,
}

class Supplier {
  String id;
  String name;
  String address;
  String? email;
  String? phone;
  bool isDeleted;
  Timestamp createdAt;
  Timestamp? updatedAt;
  SupplierStatus? status;

  Supplier({
    required this.id,
    required this.name,
    required this.address,
    this.email,
    this.phone,
    this.isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status,
  })  : createdAt = Timestamp.fromDate(createdAt ?? DateTime.now()),
        updatedAt = updatedAt != null ? Timestamp.fromDate(updatedAt) : null;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt'] as String))
          : null,
      status: json['status'] != null
          ? SupplierStatus.values.byName(json['status'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status?.toString().split('.').last,
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? address,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    bool? isDeleted,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt.toDate(),
      updatedAt: updatedAt ?? (this.updatedAt?.toDate()),
      status: status != null
          ? SupplierStatus.values.byName(status as String)
          : this.status,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, address: $address, email: $email, phone: $phone, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, isDeleted: $isDeleted)';
  }
}
