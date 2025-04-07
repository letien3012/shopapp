import '../models/product_variant.dart';
import '../models/product_option.dart';
import '../models/option_info.dart';

extension ProductOptionReadable on ProductOption {
  String toReadableString() {
    return name;
  }
}

extension ProductVariantReadable on ProductVariant {
  String toReadableString() {
    final optionsText = options.map((e) => e.toReadableString()).join(', ');
    return "$label ($optionsText)";
  }
}

extension OptionInfoReadable on OptionInfo {
  String toReadableString(Map<String, String> idToNameMap) {
    final name1 = idToNameMap[optionId1] ?? 'Không rõ';
    final name2 = idToNameMap[optionId2] ?? '';
    final optionText = [name1, name2].where((e) => e.isNotEmpty).join(' + ');
    final weightText = weight != null ? ', nặng ${weight}kg' : '';
    return "Tùy chọn: $optionText, giá ${price.toStringAsFixed(0)} VNĐ, còn lại $stock sản phẩm$weightText.";
  }
}
