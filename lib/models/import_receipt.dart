import 'package:luanvan/models/import_item.dart';

class ImportReceipt {
  String id;
  String supplierName;
  DateTime createdAt;
  double totalAmount;
  String? note;
  List<ImportItem> items;

  ImportReceipt({
    required this.id,
    required this.supplierName,
    required this.createdAt,
    required this.totalAmount,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierName': supplierName,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'note': note,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory ImportReceipt.fromMap(Map<String, dynamic> map) {
    return ImportReceipt(
      id: map['id'],
      supplierName: map['supplierName'],
      createdAt: DateTime.parse(map['createdAt']),
      totalAmount: map['totalAmount'].toDouble(),
      note: map['note'],
      items: List<ImportItem>.from(
        (map['items'] as List).map((e) => ImportItem.fromMap(e)),
      ),
    );
  }
}
