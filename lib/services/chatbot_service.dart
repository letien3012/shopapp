import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  Future<List<double>> generateEmbedding(String text) async {
    final apiKey = dotenv.env['API_KEY'];
    const url =
        'https://router.huggingface.co/hf-inference/pipeline/sentence-similarity/sentence-transformers/all-MiniLM-L6-v2';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'inputs': text,
      }),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<double>.from(data[0]['embedding']);
    } else {
      throw Exception('Failed to generate embedding');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(
      String searchKeyword) async {
    final searchEmbedding = await generateEmbedding(searchKeyword);
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    List<Map<String, dynamic>> relevantProducts = [];

    for (var doc in snapshot.docs) {
      final productDescription = doc['description'];
      final productEmbedding = await generateEmbedding(productDescription);

      final similarity = cosineSimilarity(searchEmbedding, productEmbedding);

      if (similarity > 0.7) {
        // Điều chỉnh mức độ tương đồng theo yêu cầu
        relevantProducts.add({
          'name': doc['name'],
          'description': doc['description'],
          'similarity': similarity,
        });
      }
    }

    relevantProducts.sort((a, b) => b['similarity'].compareTo(a['similarity']));
    return relevantProducts;
  }

  double cosineSimilarity(List<double> vec1, List<double> vec2) {
    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      magnitude1 += vec1[i] * vec1[i];
      magnitude2 += vec2[i] * vec2[i];
    }

    return dotProduct / (sqrt(magnitude1) * sqrt(magnitude2));
  }

  Future<String> generateAnswer(
      String query, List<Map<String, dynamic>> relevantProducts) async {
    final apiKey = dotenv.env['API_KEY'];
    const url =
        'https://api-inference.huggingface.co/models/distilbert-base-uncased';

    final context = relevantProducts.map((e) {
      return 'Product: ${e['name']} - Description: ${e['description']}';
    }).join('\n');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'text-davinci-003', // Bạn có thể chọn model khác nếu cần
        'prompt':
            'Given the following product descriptions, answer the query:\n$query\n\n$context',
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['text'];
    } else {
      throw Exception('Failed to generate answer');
    }
  }
}
