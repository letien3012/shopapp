import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/option_info.dart';

class ProductService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<String> addProduct(Product product) async {
    String productId = '';
    final docRef =
        await firebaseFirestore.collection('products').add(product.toMap());
    productId = docRef.id;
    await docRef.update({'id': docRef.id});

    // Add variants as subcollection and update their IDs
    List<ProductVariant> updatedVariants = [];
    for (int i = 0; i < product.variants.length; i++) {
      final variant = product.variants[i];
      final variantRef = await docRef.collection('variants').add({
        ...variant.toFirestore(),
        'variantIndex': i,
      });
      await variantRef.update({'id': variantRef.id});

      // Add options as subcollection of variant and update their IDs
      List<ProductOption> updatedOptions = [];
      for (int j = 0; j < variant.options.length; j++) {
        final option = variant.options[j];

        final optionRef = await variantRef.collection('options').add({
          ...option.toMap(),
          'optionIndex': j,
        });
        await optionRef.update({'id': optionRef.id});
        updatedOptions.add(option.copyWith(
          id: optionRef.id,
          optionIndex: j,
        ));
      }

      updatedVariants.add(variant.copyWith(
        id: variantRef.id,
        options: updatedOptions,
        variantIndex: i,
      ));
    }

    // Update optionInfos with option IDs
    List<OptionInfo> updatedOptionInfos = [];
    for (int i = 0; i < product.optionInfos.length; i++) {
      String? optionId1;
      String? optionId2;

      if (updatedVariants.length == 1) {
        optionId1 = updatedVariants[0].options[i].id;
      } else if (updatedVariants.length == 2) {
        int secondVariantOptionsLength = updatedVariants[1].options.length;
        int j = i ~/ secondVariantOptionsLength;
        int k = i % secondVariantOptionsLength;
        optionId1 = updatedVariants[0].options[j].id;
        optionId2 = updatedVariants[1].options[k].id;
      }

      updatedOptionInfos.add(product.optionInfos[i].copyWith(
        optionId1: optionId1,
        optionId2: optionId2,
      ));
    }

    // Update product with option IDs
    await docRef.update({
      'optionInfos': updatedOptionInfos.map((info) => info.toMap()).toList(),
    });
    return productId;
  }

  Future<List<Product>> fetchProductByShopId(String shopId) async {
    final List<Product> listProduct = [];

    QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        listProduct.add(await _fetchProductWithSubcollections(doc));
      }
    } else {
      print("Product not found!");
    }
    return listProduct.where((product) => !product.isDeleted).toList();
  }

  Future<Product> fetchProductByProductId(String productId) async {
    final docSnapshot =
        await firebaseFirestore.collection('products').doc(productId).get();
    return await _fetchProductWithSubcollections(docSnapshot);
  }

  Future<List<Product>> fetchProductsByListProductId(
      List<String> productIds) async {
    final response = await firebaseFirestore
        .collection('products')
        .where('id', whereIn: productIds)
        .get();

    final listProduct = await Future.wait(
        response.docs.map((doc) => _fetchProductWithSubcollections(doc)));
    return listProduct
        .where((product) =>
            !product.isDeleted &&
            !product.isHidden &&
            product.getMaxOptionStock() > 0)
        .toList();
  }

  Future<List<Product>> fetchAllProduct(List<String> productIds) async {
    final response = await firebaseFirestore
        .collection('products')
        .where('id', whereIn: productIds)
        .get();
    return await Future.wait(
        response.docs.map((doc) => _fetchProductWithSubcollections(doc)));
  }

  Future<List<Product>> fetchProductByCategoryId(String categoryId) async {
    final response = await firebaseFirestore
        .collection('products')
        .where('category', isEqualTo: categoryId)
        .get();
    final listProduct = await Future.wait(
        response.docs.map((doc) => _fetchProductWithSubcollections(doc)));
    return listProduct
        .where((product) => !product.isDeleted && !product.isHidden)
        .toList();
  }

  Future<void> deleteProduct(String productId) async {
    final docRef = firebaseFirestore.collection('products').doc(productId);

    // Delete all options in all variants
    final variantsSnapshot = await docRef.collection('variants').get();
    for (var variantDoc in variantsSnapshot.docs) {
      final optionsSnapshot =
          await variantDoc.reference.collection('options').get();
      for (var optionDoc in optionsSnapshot.docs) {
        await optionDoc.reference.delete();
      }
      await variantDoc.reference.delete();
    }

    // Delete the product document
    await docRef.delete();
  }

  Future<void> UpdateProduct(Product product) async {
    final docRef = firebaseFirestore.collection('products').doc(product.id);

    // Update product document
    await docRef.update(product.toMap());

    // Get existing variants
    final variantsSnapshot = await docRef.collection('variants').get();
    final existingVariants = variantsSnapshot.docs.map((doc) => doc.id).toSet();

    // Add new variants and options and update their IDs
    List<ProductVariant> updatedVariants = [];
    for (int i = 0; i < product.variants.length; i++) {
      final variant = product.variants[i];
      DocumentReference variantRef;

      // Check if variant already exists
      if (variant.id.isNotEmpty && existingVariants.contains(variant.id)) {
        variantRef = docRef.collection('variants').doc(variant.id);
        await variantRef.update({
          ...variant.toFirestore(),
          'variantIndex': i,
        });
      } else {
        variantRef = await docRef.collection('variants').add({
          ...variant.toFirestore(),
          'variantIndex': i,
        });
        await variantRef.update({'id': variantRef.id});
      }

      // Get existing options for this variant
      final optionsSnapshot = await variantRef.collection('options').get();
      final existingOptions = optionsSnapshot.docs.map((doc) => doc.id).toSet();

      // Add or update options
      List<ProductOption> updatedOptions = [];
      for (int j = 0; j < variant.options.length; j++) {
        final option = variant.options[j];
        DocumentReference optionRef;

        // Check if option already exists
        if (option.id.isNotEmpty && existingOptions.contains(option.id)) {
          optionRef = variantRef.collection('options').doc(option.id);
          await optionRef.update({
            ...option.toMap(),
            'optionIndex': j,
          });
        } else {
          optionRef = await variantRef.collection('options').add({
            ...option.toMap(),
            'optionIndex': j,
          });
          await optionRef.update({'id': optionRef.id});
        }

        updatedOptions.add(option.copyWith(
          id: optionRef.id,
          optionIndex: j,
        ));
      }

      updatedVariants.add(variant.copyWith(
        id: variantRef.id,
        options: updatedOptions,
        variantIndex: i,
      ));
    }

    // Delete variants that no longer exist
    for (var existingVariantId in existingVariants) {
      if (!updatedVariants.any((v) => v.id == existingVariantId)) {
        final variantRef = docRef.collection('variants').doc(existingVariantId);
        final optionsSnapshot = await variantRef.collection('options').get();
        for (var optionDoc in optionsSnapshot.docs) {
          await optionDoc.reference.delete();
        }
        await variantRef.delete();
      }
    }

    // Update optionInfos with option IDs
    List<OptionInfo> updatedOptionInfos = [];
    for (int i = 0; i < product.optionInfos.length; i++) {
      String? optionId1;
      String? optionId2;

      if (updatedVariants.length == 1) {
        optionId1 = updatedVariants[0].options[i].id;
      } else if (updatedVariants.length == 2) {
        int secondVariantOptionsLength = updatedVariants[1].options.length;
        int j = i ~/ secondVariantOptionsLength;
        int k = i % secondVariantOptionsLength;
        optionId1 = updatedVariants[0].options[j].id;
        optionId2 = updatedVariants[1].options[k].id;
      }

      updatedOptionInfos.add(product.optionInfos[i].copyWith(
        optionId1: optionId1,
        optionId2: optionId2,
      ));
    }

    // Update product with option IDs
    await docRef.update({
      'optionInfos': updatedOptionInfos.map((info) => info.toMap()).toList(),
    });
  }

  Future<Product> _fetchProductWithSubcollections(DocumentSnapshot doc) async {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final List<ProductVariant> variants = [];

    // Fetch variants
    final variantsSnapshot = await doc.reference.collection('variants').get();

    // Chuyển đổi thành list và sắp xếp theo variantIndex
    final variantsList = variantsSnapshot.docs.toList();
    variantsList.sort((a, b) {
      final aIndex = (a.data()['variantIndex'] as num?)?.toInt() ?? 0;
      final bIndex = (b.data()['variantIndex'] as num?)?.toInt() ?? 0;
      return aIndex.compareTo(bIndex);
    });

    for (var variantDoc in variantsList) {
      final variantData = variantDoc.data() as Map<String, dynamic>;
      final List<ProductOption> options = [];

      // Fetch options for each variant
      final optionsSnapshot =
          await variantDoc.reference.collection('options').get();

      // Chuyển đổi options thành list và sắp xếp theo optionIndex
      final optionsList = optionsSnapshot.docs.toList();
      optionsList.sort((a, b) {
        final aIndex = (a.data()['optionIndex'] as num?)?.toInt() ?? 0;
        final bIndex = (b.data()['optionIndex'] as num?)?.toInt() ?? 0;
        return aIndex.compareTo(bIndex);
      });

      for (var optionDoc in optionsList) {
        final optionData = optionDoc.data() as Map<String, dynamic>;
        options.add(ProductOption.fromMap({
          ...optionData,
          'id': optionDoc.id,
        }));
      }

      variants.add(ProductVariant(
        id: variantDoc.id,
        label: variantData['label'] as String,
        options: options,
        variantIndex: variantData['variantIndex'] as int? ?? 0,
      ));
    }

    return Product.fromMap({
      ...data,
      'id': doc.id,
      'variants': variants.map((v) => v.toMap()).toList(),
    });
  }

  Future<void> fetchProductById(String productId) async {}

  Future<void> updateProductViewCount(Product product) async {
    final docRef = firebaseFirestore.collection('products').doc(product.id);
    await docRef.set(product.toMap(), SetOptions(merge: true));
  }

  Future<void> incrementProductFavoriteCount(String productId) async {
    final docRef = firebaseFirestore.collection('products').doc(productId);
    await docRef.update({'favoriteCount': FieldValue.increment(1)});
  }

  Future<void> decrementProductFavoriteCount(String productId) async {
    final docRef = firebaseFirestore.collection('products').doc(productId);
    await docRef.update({'favoriteCount': FieldValue.increment(-1)});
  }
}
