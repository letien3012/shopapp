import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/image_feature.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ImageFeatureService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<List<List<List<double>>>> reshapeInput(Float32List flatInput) {
    List<List<List<List<double>>>> reshaped = List.generate(
        1,
        (_) => List.generate(
            224,
            (y) => List.generate(
                224,
                (x) => List.generate(3, (c) {
                      int index = (y * 224 + x) * 3 + c;
                      return flatInput[index];
                    }))));
    return reshaped;
  }

  Float32List preprocessImage(String imagePath) {
    final imageFile = File(imagePath);
    final rawImage = img.decodeImage(imageFile.readAsBytesSync())!;

    // 2. Resize ảnh về kích thước 224x224 (MobileNet yêu cầu)
    final resizedImage = img.copyResize(
      rawImage,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear, // Chất lượng resize
    );

    // 3. Chuyển ảnh thành mảng 3 chiều [224, 224, 3] (RGB)
    final List<double> inputList = [];
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // Lấy giá trị RGB và normalize về [0, 1] (MobileNet chuẩn)
        inputList.add(pixel.r / 255.0); // Red
        inputList.add(pixel.g / 255.0); // Green
        inputList.add(pixel.b / 255.0); // Blue
      }
    }

    // 4. Chuyển thành Float32List (TensorFlow Lite cần kiểu float32)
    final Float32List inputBuffer = Float32List.fromList(inputList);
    return inputBuffer;
  }

  Future<List<double>> extractImageFeatures(String imagePath) async {
    final interpreter =
        await Interpreter.fromAsset('assets/mobilenetv2.tflite');

    // Tiền xử lý ảnh (resize, normalize)
    final Float32List flatInput = preprocessImage(imagePath);
    final input = reshapeInput(flatInput);

    // Tạo output tensor với kích thước đúng [16, 1280]
    final output = List.filled(16 * 1280, 0.0).reshape([16, 1280]);
    interpreter.run(input, output);

    // Lấy vector đặc trưng đầu tiên (batch size = 1)
    return output[0].cast<double>();
  }

  Future<void> uploadImageFeature(
      List<String> imagePaths, String productId, List<String> imageUrl) async {
    for (int i = 0; i < imagePaths.length; i++) {
      final imageFeatures = await extractImageFeatures(imagePaths[i]);
      final imageFeature = ImageFeature(
        imageUrl: imageUrl[i],
        productId: productId,
        features: imageFeatures,
      );
      await firebaseFirestore
          .collection('imageFeatures')
          .add(imageFeature.toJson());
    }
  }

  // Future<List<Map<String, dynamic>>> detectObjects(File imageFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('http://192.168.33.8:5000/api/detect'),
  //   );
  //   request.files
  //       .add(await http.MultipartFile.fromPath('image', imageFile.path));

  //   var response = await request.send();
  //   if (response.statusCode == 200) {
  //     final responseData = await http.Response.fromStream(response);
  //     final data = json.decode(responseData.body);
  //     print(data);
  //     return List<Map<String, dynamic>>.from(data['detections']);
  //   } else {
  //     throw Exception('Failed to detect objects');
  //   }
  // }

  Future<List<ImageFeature>> searchSimilarImages(String queryImagePath) async {
    // List<Map<String, dynamic>> objects =
    //     await detectObjects(File(queryImagePath));
    final queryFeatures = await extractImageFeatures(queryImagePath);
    final allDocs =
        await FirebaseFirestore.instance.collection('imageFeatures').get();
    // Tính cosine similarity giữa queryFeatures và các ảnh trong DB
    final results = allDocs.docs
        .map((doc) {
          final dbFeatures = List<double>.from(doc['features']);
          final similarity = cosineSimilarity(queryFeatures, dbFeatures);

          if (similarity > 0.7) {
            return {
              'productId': doc['productId'],
              'imageUrl': doc['imageUrl'],
              'score': similarity,
              'features': dbFeatures,
            };
          }
        })
        .where((element) => element != null)
        .toList();

    if (results.isNotEmpty) {
      // Sắp xếp kết quả theo score giảm dần
      results.sort((a, b) => b!['score'].compareTo(a!['score']));
      // Lọc các productId trùng nhau, giữ lại score cao nhất
      final Map<String, Map<String, dynamic>> uniqueProducts = {};
      for (var result in results) {
        final productId = result!['productId'] as String;
        final score = result['score'] as double;
        if (!uniqueProducts.containsKey(productId) ||
            score > (uniqueProducts[productId]!['score'] as double)) {
          uniqueProducts[productId] = result;
        }
      }
      final listImageFeature = uniqueProducts.values
          .map((result) => ImageFeature(
                productId: result['productId'] as String,
                imageUrl: result['imageUrl'] as String,
                features: List<double>.from(result['features']),
              ))
          .toList();
      return listImageFeature;
    }
    return [];
  }

  Future<List<ImageFeature>> findRelatedProductsByImageUrl(
      String imageUrl) async {
    final doc = await firebaseFirestore
        .collection('imageFeatures')
        .where('imageUrl', isEqualTo: imageUrl)
        .limit(1)
        .get();
    final productId = doc.docs.first['productId'];
    final queryFeatures = List<double>.from(doc.docs.first['features']);
    final allDocs =
        await FirebaseFirestore.instance.collection('imageFeatures').get();
    // Tính cosine similarity giữa queryFeatures và các ảnh trong DB
    final results = allDocs.docs
        .map((doc) {
          if (doc['productId'] != productId) {
            final dbFeatures = List<double>.from(doc['features']);
            final similarity = cosineSimilarity(queryFeatures, dbFeatures);

            if (similarity > 0.7) {
              return {
                'productId': doc['productId'],
                'imageUrl': doc['imageUrl'],
                'score': similarity,
                'features': dbFeatures,
              };
            }
          }
        })
        .where((element) => element != null)
        .toList();

    if (results.isNotEmpty) {
      // Sắp xếp kết quả theo score giảm dần
      results.sort((a, b) => b!['score'].compareTo(a!['score']));
      // Lọc các productId trùng nhau, giữ lại score cao nhất
      final Map<String, Map<String, dynamic>> uniqueProducts = {};
      for (var result in results) {
        final productId = result!['productId'] as String;
        final score = result['score'] as double;
        if (!uniqueProducts.containsKey(productId) ||
            score > (uniqueProducts[productId]!['score'] as double)) {
          uniqueProducts[productId] = result;
        }
      }
      final listImageFeature = uniqueProducts.values
          .map((result) => ImageFeature(
                productId: result['productId'] as String,
                imageUrl: result['imageUrl'] as String,
                features: List<double>.from(result['features']),
              ))
          .toList();
      return listImageFeature;
    }
    return [];
  }

// Hàm tính cosine similarity
  double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }
}
