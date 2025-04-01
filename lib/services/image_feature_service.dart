// import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// class ImageFeatureService {
//   static const int inputSize = 224; // Kích thước input cho model
//   late Interpreter _interpreter;

//   Future<void> initialize() async {
//     // Load model từ assets
//     _interpreter = await Interpreter.fromAsset(
//         'assets/mobilenet_v2_feature_extractor.tflite');
//   }

//   Future<List<double>> extractFeatures(File imageFile) async {
//     // Đọc và resize ảnh
//     final image = img.decodeImage(await imageFile.readAsBytes())!;
//     final resizedImage = img.copyResize(
//       image,
//       width: inputSize,
//       height: inputSize,
//     );

//     // Chuyển ảnh thành tensor
//     var input = List.generate(
//       1,
//       (index) => List.generate(
//         inputSize,
//         (y) => List.generate(
//           inputSize,
//           (x) {
//             final pixel = resizedImage.getPixel(x, y);
//             // Normalize pixel values to [-1, 1]
//             return [
//               (img.getRed(pixel) / 127.5) - 1,
//               (img.getGreen(pixel) / 127.5) - 1,
//               (img.getBlue(pixel) / 127.5) - 1,
//             ];
//           },
//         ),
//       ),
//     );

//     // Output tensor
//     var outputShape = _interpreter.getOutputTensor(0).shape;
//     var output = List.generate(
//       outputShape[0],
//       (index) => List<double>.filled(outputShape[1], 0),
//     );

//     // Run inference
//     _interpreter.run(input, output);

//     // Convert output to 1D list
//     return output[0];
//   }

//   void dispose() {
//     _interpreter.close();
//   }
// }
