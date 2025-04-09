import 'package:luanvan/models/import_item.dart';
import 'package:luanvan/models/supplier.dart';

enum ImportReceiptStatus {
  pending,
  completed,
  cancelled,
}

class ImportReceipt {
  String id;
  Supplier supplier;
  String code;
  ImportReceiptStatus status;
  DateTime createdAt;
  DateTime expectedImportDate;
  String? note;
  List<ImportItem> items;

  ImportReceipt({
    required this.id,
    required this.code,
    required this.supplier,
    required this.status,
    required this.createdAt,
    required this.expectedImportDate,
    this.note,
    required this.items,
  });

  ImportReceipt copyWith({
    String? id,
    String? code,
    Supplier? supplier,
    ImportReceiptStatus? status,
    DateTime? createdAt,
    DateTime? expectedImportDate,
    String? note,
    List<ImportItem>? items,
  }) {
    return ImportReceipt(
      id: id ?? this.id,
      code: code ?? this.code,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expectedImportDate: expectedImportDate ?? this.expectedImportDate,
      note: note ?? this.note,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'supplier': supplier.toJson(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expectedImportDate': expectedImportDate.toIso8601String(),
      'note': note,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory ImportReceipt.fromMap(Map<String, dynamic> map) {
    return ImportReceipt(
      id: map['id'],
      code: map['code'],
      supplier: Supplier.fromJson(map['supplier']),
      status: ImportReceiptStatus.values.byName(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
      expectedImportDate: DateTime.parse(map['expectedImportDate']),
      note: map['note'],
      items: List<ImportItem>.from(
        (map['items'] as List).map((e) => ImportItem.fromMap(e)),
      ),
    );
  }
}
