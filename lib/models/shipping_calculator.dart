import 'package:luanvan/models/shipping_method.dart';

class ShippingCalculator {
  // Tính chi phí dựa trên trọng lượng (kg) và phương thức
  static double calculateShippingCost({
    required String methodName,
    required double weight,
    double baseDistance = 100.0,
  }) {
    final method = ShippingMethod.getMethodByName(methodName);
    double baseCost = method.cost;

    double weightFactor = weight > 1.0 ? weight * 0.5 : 0.0;
    double totalCost = baseCost + weightFactor;

    // Có thể thêm yếu tố khoảng cách nếu cần
    // double distanceFactor = baseDistance / 100 * 0.1; // 0.1$ mỗi 100km
    // totalCost += distanceFactor;

    return totalCost;
  }
}
