// Class để lưu lịch sử trạng thái đơn hàng
import 'package:luanvan/models/order.dart';

class OrderStatusHistory {
  OrderStatus status; // Trạng thái
  DateTime timestamp; // Thời gian thay đổi trạng thái
  String? note; // Ghi chú (nếu có)

  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
  });

  // Chuyển từ Map sang OrderStatusHistory
  factory OrderStatusHistory.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistory(
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  // Chuyển từ OrderStatusHistory sang Map
  Map<String, dynamic> toMap() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  // Chuyển từ JSON sang OrderStatusHistory
  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }

  // Chuyển từ OrderStatusHistory sang JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
