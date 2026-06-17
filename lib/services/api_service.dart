import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';

/// Centralized API service with:
/// - Persistent http.Client (reuses TCP connections — faster than one-shot gets)
/// - In-memory cache with 5-minute TTL (avoids re-fetching on tab switches)
/// - Structured error handling
class ApiService {
  static const String _baseUrl = 'https://healix-rgwin.onrender.com/api/v1';
  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _tag = 'ApiService';

  /// Shared client — keeps connections alive (HTTP keep-alive)
  static final http.Client _client = http.Client();

  // ─── In-memory cache ────────────────────────────────────────────────────────

  static List<Product>? _cachedProducts;
  static List<Category>? _cachedCategories;
  static DateTime? _productsCachedAt;
  static DateTime? _categoriesCachedAt;

  static bool _isFresh(DateTime? cachedAt) {
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) < _cacheTtl;
  }

  /// Clear all caches (call this after a data mutation like adding a product)
  static void clearCache() {
    _cachedProducts = null;
    _cachedCategories = null;
    _productsCachedAt = null;
    _categoriesCachedAt = null;
    developer.log('🗑️ [API] Cache cleared', name: _tag);
  }

  // ─── Products ────────────────────────────────────────────────────────────────

  static Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh(_productsCachedAt) && _cachedProducts != null) {
      developer.log('⚡ [API] Products served from cache (${_cachedProducts!.length} items)', name: _tag);
      return _cachedProducts!;
    }

    developer.log('📡 [API] GET $_baseUrl/products/', name: _tag);
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/products/'))
          .timeout(_timeout, onTimeout: () => throw Exception('Request timed out after ${_timeout.inSeconds}s'));

      developer.log('📥 [API] Products status: ${response.statusCode}', name: _tag);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final products = data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        // Store in cache
        _cachedProducts = products;
        _productsCachedAt = DateTime.now();
        developer.log('✅ [API] Parsed ${products.length} products', name: _tag);
        return products;
      } else {
        developer.log('❌ [API] Products error ${response.statusCode}', name: _tag);
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('💥 [API] Products exception: $e', name: _tag, error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ─── Categories ──────────────────────────────────────────────────────────────

  static Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh(_categoriesCachedAt) && _cachedCategories != null) {
      developer.log('⚡ [API] Categories served from cache (${_cachedCategories!.length} items)', name: _tag);
      return _cachedCategories!;
    }

    developer.log('📡 [API] GET $_baseUrl/categories/', name: _tag);
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/categories/'))
          .timeout(_timeout);

      developer.log('📥 [API] Categories status: ${response.statusCode}', name: _tag);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        _cachedCategories = categories;
        _categoriesCachedAt = DateTime.now();
        developer.log('✅ [API] Parsed ${categories.length} categories', name: _tag);
        return categories;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('💥 [API] Categories exception: $e', name: _tag, error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ─── Enquiries ────────────────────────────────────────────────────────────────

  static Future<bool> sendEnquiry(Map<String, dynamic> enquiryData) async {
    developer.log('📡 [API] POST enquiry for: ${enquiryData['name']}', name: _tag);
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/enquiries/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(enquiryData),
          )
          .timeout(_timeout);

      developer.log('📥 [API] Enquiry response: ${response.statusCode}', name: _tag);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, stack) {
      developer.log('💥 [API] Enquiry exception: $e', name: _tag, error: e, stackTrace: stack);
      rethrow;
    }
  }
}
