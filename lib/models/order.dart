import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/order_history.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/order_item.dart';

enum OrderStatus {
  pending, // Đang chờ xử lý
  processing, // Đang xử lý
  shipped, // Đã giao cho đơn vị vận chuyển
  delivered, // Đã giao hàng
  cancelled, // Đã hủy
  returned, // Đã trả hàng
  reviewed, // Đã đánh giá
}

// Enum để định nghĩa phương thức thanh toán
enum PaymentMethod {
  cod, // Thanh toán khi nhận hàng
  creditCard, // Thẻ tín dụng
  eWallet, // Ví điện tử (ShopeePay, ví khác)
  bankTransfer, // Chuyển khoản ngân hàng
}

class Order {
  String id;
  List<OrderItem> item;
  String shopId;
  ShippingMethod shipMethod;
  String userId;
  OrderStatus status;
  DateTime createdAt;
  DateTime? updateAt;
  Address receiveAdress;
  Address? pickUpAdress;
  PaymentMethod paymentMethod;
  double totalProductPrice;
  double totalShipFee;
  double totalPrice;
  List<OrderStatusHistory> statusHistory;
  String? trackingNumber;
  String? shippingCode;
  DateTime? estimatedDeliveryDate;
  DateTime? actualDeliveryDate;

  Order({
    required this.id,
    required this.item,
    required this.shopId,
    required this.userId,
    required this.shipMethod,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updateAt,
    required this.receiveAdress,
    this.paymentMethod = PaymentMethod.cod,
    required this.totalProductPrice,
    required this.totalShipFee,
    required this.totalPrice,
    this.statusHistory = const [],
    this.trackingNumber,
    this.shippingCode,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.pickUpAdress,
  });

  // Chuyển từ Map sang Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      item: (map['item'] as List<dynamic>)
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      shopId: map['shopId'] as String,
      userId: map['userId'] as String,
      shipMethod:
          ShippingMethod.fromMap(map['shipMethod'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
        orElse: () => PaymentMethod.cod,
      ),
      totalProductPrice: (map['totalProductPrice'] as num).toDouble(),
      totalShipFee: (map['totalShipFee'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updateAt: map['updateAt'] != null
          ? (map['updateAt'] as Timestamp).toDate()
          : null,
      receiveAdress:
          Address.fromMap(map['receiveAdress'] as Map<String, dynamic>),
      pickUpAdress: map['pickUpAddress'] != null
          ? Address.fromMap(map['pickUpAddress'] as Map<String, dynamic>)
          : null,
      statusHistory: (map['statusHistory'] as List<dynamic>?)
              ?.map(
                  (e) => OrderStatusHistory.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      trackingNumber: map['trackingNumber'] as String?,
      shippingCode: map['shippingCode'] as String?,
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? (map['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      actualDeliveryDate: map['actualDeliveryDate'] != null
          ? (map['actualDeliveryDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Chuyển từ Order sang Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item.map((e) => e.toMap()).toList(),
      'shopId': shopId,
      'userId': userId,
      'shipMethod': shipMethod.toMap(),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString(),
      'totalProductPrice': totalProductPrice,
      'totalShipFee': totalShipFee,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updateAt': updateAt != null ? Timestamp.fromDate(updateAt!) : null,
      'receiveAdress': receiveAdress.toMap(),
      'pickUpAddress': pickUpAdress?.toMap(),
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'trackingNumber': trackingNumber,
      'shippingCode': shippingCode,
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'actualDeliveryDate': actualDeliveryDate != null
          ? Timestamp.fromDate(actualDeliveryDate!)
          : null,
    };
  }

  // Chuyển từ JSON sang Order
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      item: (json['item'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      shopId: json['shopId'] ?? '',
      userId: json['userId'] ?? '',
      shipMethod:
          ShippingMethod.fromMap(json['shipMethod'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updateAt:
          json['updateAt'] != null ? DateTime.parse(json['updateAt']) : null,
      receiveAdress: Address.fromMap(json['receiveAdress'] ?? {}),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
        orElse: () => PaymentMethod.cod,
      ),
      totalProductPrice: (json['totalProductPrice'] as num?)?.toDouble() ?? 0.0,
      totalShipFee: (json['totalShipFee'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map(
                  (e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trackingNumber: json['trackingNumber'],
      shippingCode: json['shippingCode'],
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'])
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'])
          : null,
      pickUpAdress: json['pickUpAddress'] != null
          ? Address.fromMap(json['pickUpAddress'] as Map<String, dynamic>)
          : null,
    );
  }

  // Chuyển từ Order sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.map((e) => e.toMap()).toList(),
      'shopId': shopId,
      'userId': userId,
      'shipMethod': shipMethod.toMap(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
      'receiveAdress': receiveAdress.toMap(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'totalProductPrice': totalProductPrice,
      'totalShipFee': totalShipFee,
      'totalPrice': totalPrice,
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'trackingNumber': trackingNumber,
      'shippingCode': shippingCode,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'pickUpAddress': pickUpAdress?.toMap(),
    };
  }

  // Phương thức copyWith để tạo bản sao với các giá trị thay đổi
  Order copyWith({
    String? id,
    List<OrderItem>? item,
    String? shopId,
    String? userId,
    ShippingMethod? shipMethod,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updateAt,
    Address? receiveAdress,
    PaymentMethod? paymentMethod,
    double? totalProductPrice,
    double? totalShipFee,
    double? totalPrice,
    List<OrderStatusHistory>? statusHistory,
    String? trackingNumber,
    String? shippingCode,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    Address? pickUpAdress,
  }) {
    return Order(
      id: id ?? this.id,
      item: item ?? this.item,
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      shipMethod: shipMethod ?? this.shipMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      receiveAdress: receiveAdress ?? this.receiveAdress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalProductPrice: totalProductPrice ?? this.totalProductPrice,
      totalShipFee: totalShipFee ?? this.totalShipFee,
      totalPrice: totalPrice ?? this.totalPrice,
      statusHistory: statusHistory ?? this.statusHistory,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippingCode: shippingCode ?? this.shippingCode,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      pickUpAdress: pickUpAdress ?? this.pickUpAdress,
    );
  }

  // Phương thức để cập nhật trạng thái đơn hàng
  Order updateStatus(OrderStatus newStatus, {String? note}) {
    return copyWith(
      status: newStatus,
      updateAt: DateTime.now(),
      statusHistory: [
        ...statusHistory,
        OrderStatusHistory(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
        ),
      ],
    );
  }

  // Phương thức để tính lại tổng giá (nếu cần)
  double calculateTotalPrice() {
    return totalProductPrice + totalShipFee;
  }
}
