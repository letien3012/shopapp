import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/order_history.dart';
import 'package:luanvan/models/shipping_method.dart';

enum OrderStatus {
  pending, // Đang chờ xử lý
  processing, // Đang xử lý
  shipped, // Đã giao cho đơn vị vận chuyển
  delivered, // Đã giao hàng
  cancelled, // Đã hủy
  returned, // Đã trả hàng
}

// Enum để định nghĩa phương thức thanh toán
enum PaymentMethod {
  cod, // Thanh toán khi nhận hàng
  creditCard, // Thẻ tín dụng
  eWallet, // Ví điện tử (ShopeePay, ví khác)
  bankTransfer, // Chuyển khoản ngân hàng
}

class Order {
  String id; // ID đơn hàng
  List<CartItem> item; // Danh sách các mục trong đơn hàng
  String shopId; // ID cửa hàng
  ShippingMethod shipMethod; // Phương thức vận chuyển
  String userId; // ID người dùng (người mua)
  OrderStatus status; // Trạng thái đơn hàng
  DateTime createdAt; // Thời gian tạo đơn hàng
  DateTime? updateAt; // Thời gian cập nhật đơn hàng
  Address receiveAdress; // Địa chỉ nhận hàng
  PaymentMethod paymentMethod; // Phương thức thanh toán
  double totalProductPrice; // Tổng tiền hàng
  double totalShipFee; // Tổng phí vận chuyển
  double totalPrice; // Tổng thanh toán
  List<OrderStatusHistory> statusHistory; // Lịch sử trạng thái đơn hàng
  String? trackingNumber; // Mã vận đơn
  String? shippingCode; // Mã vận đơn (mã bưu điện)
  DateTime? estimatedDeliveryDate; // Ngày giao hàng dự kiến
  DateTime? actualDeliveryDate; // Ngày giao hàng thực tế
  double discountAmount; // Số tiền giảm giá (nếu có)
  String? discountCode; // Mã giảm giá (nếu có)
  String? note; // Ghi chú của người mua (nếu có)
  bool isRated; // Đã đánh giá đơn hàng chưa

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
    this.discountAmount = 0.0,
    this.discountCode,
    this.note,
    this.isRated = false,
  });

  // Chuyển từ Map sang Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      item: (map['item'] as List<dynamic>?)
              ?.map((e) => CartItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      shopId: map['shopId'] ?? '',
      userId: map['userId'] ?? '',
      shipMethod:
          ShippingMethod.fromMap(map['shipMethod'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updateAt:
          map['updateAt'] != null ? DateTime.parse(map['updateAt']) : null,
      receiveAdress: Address.fromMap(map['receiveAdress'] ?? {}),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
        orElse: () => PaymentMethod.cod,
      ),
      totalProductPrice: (map['totalProductPrice'] as num?)?.toDouble() ?? 0.0,
      totalShipFee: (map['totalShipFee'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      statusHistory: (map['statusHistory'] as List<dynamic>?)
              ?.map(
                  (e) => OrderStatusHistory.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      trackingNumber: map['trackingNumber'],
      shippingCode: map['shippingCode'],
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? DateTime.parse(map['estimatedDeliveryDate'])
          : null,
      actualDeliveryDate: map['actualDeliveryDate'] != null
          ? DateTime.parse(map['actualDeliveryDate'])
          : null,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      discountCode: map['discountCode'] ?? '',
      note: map['note'] ?? '',
      isRated: map['isRated'] ?? false,
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
      'createdAt': createdAt.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
      'receiveAdress': receiveAdress.toMap(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'totalProductPrice': totalProductPrice,
      'totalShipFee': totalShipFee,
      'totalPrice': totalPrice,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'trackingNumber': trackingNumber,
      'shippingCode': shippingCode,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'discountAmount': discountAmount,
      'discountCode': discountCode,
      'note': note,
      'isRated': isRated,
    };
  }

  // Chuyển từ JSON sang Order
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      item: (json['item'] as List<dynamic>?)
              ?.map((e) => CartItem.fromMap(e as Map<String, dynamic>))
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
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      discountCode: json['discountCode'],
      note: json['note'],
      isRated: json['isRated'] ?? false,
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
      'discountAmount': discountAmount,
      'discountCode': discountCode,
      'note': note,
      'isRated': isRated,
    };
  }

  // Phương thức copyWith để tạo bản sao với các giá trị thay đổi
  Order copyWith({
    String? id,
    String? productId,
    List<CartItem>? item,
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
    double? discountAmount,
    String? discountCode,
    String? note,
    bool? isRated,
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
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
      note: note ?? this.note,
      isRated: isRated ?? this.isRated,
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
    return totalProductPrice + totalShipFee - discountAmount;
  }
}
