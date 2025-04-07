import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/category.dart';
import 'package:luanvan/models/option_info.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/rag/product_extension.dart';

Future<List<Category>> getCategories() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('categories').get();
  return snapshot.docs.map((e) => Category.fromJson(e.data())).toList();
}

Map<String, String> buildOptionIdToNameMap(List<ProductVariant> variants) {
  final map = <String, String>{};
  for (final variant in variants) {
    for (final option in variant.options) {
      map[option.id] = option.name;
    }
  }
  return map;
}

List<String> generateVariantChunks(List<ProductVariant> variants) {
  return variants.map((variant) {
    return "Biến thể sản phẩm: ${variant.toReadableString()}.";
  }).toList();
}

List<String> generateOptionInfoChunks(
    List<OptionInfo> optionInfos, Map<String, String> idToNameMap) {
  return optionInfos.map((info) => info.toReadableString(idToNameMap)).toList();
}

Future<List<String>> generateProductChunks(Product product) async {
  if (product.isDeleted ||
      product.isHidden ||
      product.getMaxOptionStock() == 0) {
    return [];
  }
  final idToNameMap = buildOptionIdToNameMap(product.variants);
  final categories = await getCategories();
  return [
    "Tên sản phẩm: ${product.name}.",
    "Mô tả: ${product.description}.",
    "Danh mục: ${categories.firstWhere((element) => element.id == product.category).name}.",
    if (product.optionInfos.isNotEmpty)
      ...generateOptionInfoChunks(product.optionInfos, idToNameMap),
    if (product.variants.isNotEmpty) ...generateVariantChunks(product.variants),
    if (product.price != null)
      "Giá chung: ${product.price!.toStringAsFixed(0)} VNĐ.",
    "Link ảnh: ${product.imageUrl.join(', ')}",
  ];
}
