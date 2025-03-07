import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Để sử dụng Timestamp

class SellerRegistration {
  final String registrationId;
  final String userId;
  final String name;
  final String address;
  final String phoneNumber;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  SellerRegistration({
    required this.registrationId,
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  SellerRegistration copyWith({
    String? registrationId,
    String? userId,
    String? name,
    String? address,
    String? taxId,
    String? phoneNumber,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return SellerRegistration(
      registrationId: registrationId ?? this.registrationId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory SellerRegistration.fromMap(Map<String, dynamic> map) {
    return SellerRegistration(
      registrationId: map['registrationId'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phoneNumber'] as String,
      status: map['status'] as String,
      submittedAt: (map['submittedAt'] is Timestamp)
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.parse(map['submittedAt'] as String),
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] is Timestamp
              ? (map['reviewedAt'] as Timestamp).toDate()
              : DateTime.parse(map['reviewedAt'] as String))
          : null,
      reviewedBy: map['reviewedBy'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  factory SellerRegistration.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SellerRegistration(
      registrationId: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      address: data['address'] as String,
      phoneNumber: data['phoneNumber'] as String,
      status: data['status'] as String,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewedBy: data['reviewedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  // Chuyển đổi từ đối tượng SellerRegistration sang Map
  Map<String, dynamic> toMap() {
    return {
      'registrationId': registrationId,
      'userId': userId,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }

  String toJson() => json.encode(toMap());

  factory SellerRegistration.fromJson(String source) =>
      SellerRegistration.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SellerRegistration(registrationId: $registrationId, userId: $userId, name: $name, '
        'address: $address, phoneNumber: $phoneNumber, status: $status, '
        'submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, '
        'rejectionReason: $rejectionReason)';
  }
}
