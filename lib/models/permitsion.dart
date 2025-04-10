enum Permission {
  manageOrders,
  manageUsers,
  manageProducts,
  viewRevenue,
  analyzeSales,
  manageCategories,
  manageSuppliers,
  manageInventory,
  manageBanners,
  customerSupport;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission.values.firstWhere(
      (e) => e.name == map['name'],
      orElse: () => throw Exception('Invalid permission name: ${map['name']}'),
    );
  }

  @override
  String toString() {
    return name
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
