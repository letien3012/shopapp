import 'package:luanvan/models/shipping_method.dart';

class ShippingCalculator {
  static double calculateShippingCost({
    required String methodName,
    required double weight,
    double baseDistance = 100.0,
    bool includeDistanceFactor = false,
  }) {
    final method = ShippingMethod.getMethodByName(methodName);
    double baseCost = method.cost;

    double weightFactor = weight > 1000.0
        ? (weight - 1000.0) / 1000 * method.additionalWeightCost
        : 0.0;
    // print(weightFactor);
    double totalCost = baseCost + weightFactor;
    if (includeDistanceFactor) {
      double distanceFactor = (baseDistance / 100) * 2.0;
      totalCost += distanceFactor;
    }
    return totalCost < 0 ? 0 : totalCost;
  }
}
