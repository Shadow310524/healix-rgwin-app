import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'https://healix-rgwin.onrender.com/api/v1';

  static Future<List<Product>> getProducts() async {
    developer.log('📡 [API] Calling GET $baseUrl/products/', name: 'ApiService');
    try {
      final uri = Uri.parse('$baseUrl/products/');
      developer.log('📡 [API] URI parsed: $uri', name: 'ApiService');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('⏰ [API] Request timed out after 15 seconds!', name: 'ApiService');
          throw Exception('Request timed out');
        },
      );

      developer.log('📥 [API] Response status: ${response.statusCode}', name: 'ApiService');
      developer.log('📥 [API] Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}', name: 'ApiService');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        developer.log('✅ [API] Parsed ${data.length} products successfully', name: 'ApiService');
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        developer.log('❌ [API] Server error ${response.statusCode}: ${response.body}', name: 'ApiService');
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      developer.log('💥 [API] Exception: $e', name: 'ApiService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<List<Category>> getCategories() async {
    developer.log('📡 [API] Calling GET $baseUrl/categories/', name: 'ApiService');
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/')).timeout(
        const Duration(seconds: 15),
      );
      developer.log('📥 [API] Categories response status: ${response.statusCode}', name: 'ApiService');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        developer.log('✅ [API] Parsed ${data.length} categories', name: 'ApiService');
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('💥 [API] Categories exception: $e', name: 'ApiService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<bool> sendEnquiry(Map<String, dynamic> enquiryData) async {
    developer.log('📡 [API] Sending enquiry: $enquiryData', name: 'ApiService');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enquiries/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(enquiryData),
      ).timeout(const Duration(seconds: 15));
      developer.log('📥 [API] Enquiry response: ${response.statusCode}', name: 'ApiService');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, stackTrace) {
      developer.log('💥 [API] Enquiry exception: $e', name: 'ApiService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
