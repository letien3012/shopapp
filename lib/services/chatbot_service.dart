import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/rag/product_chunk.dart';

class ChatbotService {
  Future<List<double>> generateEmbedding(String text) async {
    final apiKey = dotenv.env['API_KEY'];
    const url =
        'https://router.huggingface.co/hf-inference/pipeline/feature-extraction/intfloat/multilingual-e5-large-instruct';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'inputs': text}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<double>.from(data);
    } else {
      throw Exception('Failed to generate embedding');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(
      String searchKeyword) async {
    // Lấy embedding của từ khóa tìm kiếm
    final List<double> searchEmbedding = await generateEmbedding(searchKeyword);

    // Truy vấn toàn bộ sản phẩm từ Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('product_embedding').get();

    List<Map<String, dynamic>> relevantProducts = [];

    // Tính toán độ tương đồng giữa embedding tìm kiếm và các sản phẩm
    for (var doc in snapshot.docs) {
      final embeddings = doc['embeddings'].cast<double>();
      final similarity = cosineSimilarity(searchEmbedding, embeddings);
      if (similarity > 0.7) {
        // Nếu độ tương đồng lớn hơn 0.7, thêm sản phẩm vào danh sách
        relevantProducts.add({
          'id': doc['productId'], // Chỉ lưu id
          'similarity': similarity,
        });
      }
    }

    // Sắp xếp danh sách sản phẩm theo độ tương đồng giảm dần
    relevantProducts.sort((a, b) => b['similarity'].compareTo(a['similarity']));

    // Lấy thông tin chi tiết của từng sản phẩm
    for (int i = 0; i < relevantProducts.length; i++) {
      final productId = relevantProducts[i]['id'];
      // Truy vấn thông tin chi tiết sản phẩm từ Firestore
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productDoc.exists) {
        relevantProducts[i]['name'] = productDoc['name'];
        relevantProducts[i]['description'] = productDoc['description'];
        relevantProducts[i]['price'] =
            productDoc['price']; // Lấy giá của sản phẩm
      }
    }

    return relevantProducts;
  }

  double cosineSimilarity(List<double> vec1, List<double> vec2) {
    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    // Tính dot product và magnitude của cả hai vector
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      magnitude1 += vec1[i] * vec1[i];
      magnitude2 += vec2[i] * vec2[i];
    }

    // Trả về độ tương đồng cosine
    return dotProduct / (sqrt(magnitude1) * sqrt(magnitude2));
  }

  Future<String> generateAnswer(
    String query,
  ) async {
    final apiKey = dotenv.env['API_KEY'];
    const url =
        'https://router.huggingface.co/novita/v3/openai/chat/completions';
    final allProducts = await FirebaseFirestore.instance
        .collection('products')
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false)
        .get();
    final context = await Future.wait(allProducts.docs.map((e) async {
      return await generateProductChunks(Product.fromFirestore(e));
    }));
    print(context);
    // Xây dựng prompt chi tiết bằng tiếng Việt với câu hỏi và ngữ cảnh
    final prompt = '''
    Bạn là một trợ lý bán hàng chuyên nghiệp.
    Đây là danh sách sản phẩm có trong cửa hàng
    $context
    Câu hỏi của khách hàng: $query

    Nếu câu hỏi liên quan đến sản phẩm, hãy trả lời dựa trên danh sách sản phẩm một cách tự nhiên và thân thiện.
    Nếu không liên quan đến sản phẩm, hãy trả lời 1 cách tự nhiên và hợp lý nhất.
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1024,
        "model": "deepseek/deepseek-v3-0324",
        'stream': false,
        // 'inputs': prompt,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final responseData = utf8.decode(response.bodyBytes);
      final data = json.decode(responseData);
      // Kiểm tra nếu trường 'choices' và 'text' tồn tại trong dữ liệu trả về
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] ??
            'Không tìm thấy câu trả lời.';
      } else {
        throw Exception('Không tìm thấy câu trả lời trong phản hồi');
      }
    } else {
      // Xử lý lỗi nếu API trả về status code khác 200
      throw Exception('Không thể tạo câu trả lời: ${response.statusCode}');
    }
  }
  // Stream<String> generateAnswerStream(String query, String context) async* {
  //   final apiKey = dotenv.env['API_KEY'];
  //   const url =
  //       'https://router.huggingface.co/novita/v3/openai/chat/completions';

  //   final request = http.Request('POST', Uri.parse(url));
  //   request.headers.addAll({
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $apiKey',
  //   });

  //   final prompt = '''
  //     Bạn là một trợ lý bán hàng chuyên nghiệp.
  //     Đây là danh sách sản phẩm có trong cửa hàng:
  //     $context

  //     Câu hỏi của khách hàng: $query

  //     Nếu câu hỏi liên quan đến sản phẩm, hãy trả lời dựa trên danh sách sản phẩm một cách tự nhiên và thân thiện.
  //     Nếu không liên quan đến sản phẩm, hãy trả lời một cách tự nhiên và hợp lý nhất.
  //     ''';

  //   request.body = jsonEncode({
  //     'messages': [
  //       {'role': 'user', 'content': prompt}
  //     ],
  //     'model': 'deepseek/deepseek-v3-0324',
  //     'stream': true,
  //     'max_tokens': 1024,
  //   });

  //   final response = await request.send();

  //   if (response.statusCode == 200) {
  //     final stream = response.stream
  //         .transform(utf8.decoder)
  //         .transform(const LineSplitter());

  //     await for (final line in stream) {
  //       if (line.startsWith('data:')) {
  //         final jsonLine = line.replaceFirst('data: ', '').trim();
  //         if (jsonLine == '[DONE]') break;
  //         final data = json.decode(jsonLine);
  //         final content = data['choices'][0]['delta']['content'];
  //         if (content != null) yield content;
  //       }
  //     }
  //   } else {
  //     throw Exception('Streaming thất bại: ${response.statusCode}');
  //   }
  // }
}
