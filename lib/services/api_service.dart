import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';

/// Centralized API service with:
/// - Persistent http.Client (reuses TCP connections)
/// - In-memory and Disk caching (Offline support)
/// - Structured error handling
class ApiService {
  static const String _baseUrl = 'https://healix-rgwin.onrender.com/api/v1';
  static const Duration _timeout = Duration(seconds: 60);
  static const Duration _cacheTtl = Duration(minutes: 60); // 1 hour TTL for offline cache
  static const String _tag = 'ApiService';

  static final http.Client _client = http.Client();

  // In-memory caches to avoid hitting disk/parsing repeatedly in same session
  static List<Product>? _memProducts;
  static List<Category>? _memCategories;

  static Future<bool> _isFresh(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('${key}_time');
    if (timestamp == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedAt) < _cacheTtl;
  }

  static Future<void> _saveToDisk(String key, List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
    await prefs.setInt('${key}_time', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<dynamic>?> _loadFromDisk(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(key);
    if (str != null) {
      return json.decode(str) as List<dynamic>;
    }
    return null;
  }

  /// Clear all caches
  static Future<void> clearCache() async {
    _memProducts = null;
    _memCategories = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('products');
    await prefs.remove('products_time');
    await prefs.remove('categories');
    await prefs.remove('categories_time');
    developer.log('🗑️ [API] Cache cleared', name: _tag);
  }

  // ─── Products ────────────────────────────────────────────────────────────────

  static Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    // 1. Check in-memory cache first
    if (!forceRefresh && _memProducts != null && await _isFresh('products')) {
      developer.log('⚡ [API] Products served from MEMORY', name: _tag);
      return _memProducts!;
    }

    // 2. Check disk cache if not forcing refresh
    if (!forceRefresh) {
      final diskData = await _loadFromDisk('products');
      if (diskData != null && await _isFresh('products')) {
        developer.log('⚡ [API] Products served from DISK CACHE', name: _tag);
        _memProducts = diskData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        return _memProducts!;
      }
    }

    // 3. Fetch from Network
    developer.log('📡 [API] GET $_baseUrl/products/', name: _tag);
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/products/'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final products = data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        
        // Save to cache
        _memProducts = products;
        final jsonList = products.map((p) => p.toJson()).toList();
        await _saveToDisk('products', jsonList);
        
        developer.log('✅ [API] Parsed and cached ${products.length} products', name: _tag);
        return products;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('💥 [API] Products network exception: $e', name: _tag, error: e, stackTrace: stack);
      // Fallback: If network fails (e.g. no internet), return stale disk cache if available
      final staleData = await _loadFromDisk('products');
      if (staleData != null) {
        developer.log('⚠️ [API] Network failed, serving STALE DISK CACHE', name: _tag);
        _memProducts = staleData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        return _memProducts!;
      }
      if (e is SocketException || e is TimeoutException) {
        throw Exception("No internet connection or server timeout. Please check your network and try again.");
      }
      throw Exception("Unable to load products due to a server error. Please try again.");
    }
  }

  // ─── Categories ──────────────────────────────────────────────────────────────

  static Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _memCategories != null && await _isFresh('categories')) {
      return _memCategories!;
    }

    if (!forceRefresh) {
      final diskData = await _loadFromDisk('categories');
      if (diskData != null && await _isFresh('categories')) {
        _memCategories = diskData.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        return _memCategories!;
      }
    }

    developer.log('📡 [API] GET $_baseUrl/categories/', name: _tag);
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/categories/'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        
        _memCategories = categories;
        final jsonList = categories.map((c) => c.toJson()).toList();
        await _saveToDisk('categories', jsonList);
        
        developer.log('✅ [API] Parsed and cached ${categories.length} categories', name: _tag);
        return categories;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('💥 [API] Categories network exception: $e', name: _tag, error: e, stackTrace: stack);
      final staleData = await _loadFromDisk('categories');
      if (staleData != null) {
        _memCategories = staleData.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        return _memCategories!;
      }
      if (e is SocketException || e is TimeoutException) {
        throw Exception("No internet connection or server timeout. Please check your network and try again.");
      }
      throw Exception("Unable to load categories due to a server error. Please try again.");
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Server failed to accept enquiry. Status: ${response.statusCode}");
      }
    } catch (e, stack) {
      developer.log('💥 [API] Enquiry exception: $e', name: _tag, error: e, stackTrace: stack);
      if (e is SocketException || e is TimeoutException) {
        throw Exception("No internet connection or server timeout. Please check your network and try again.");
      }
      throw Exception("Failed to send message. Please try again.");
    }
  }

  // ─── Analytics ────────────────────────────────────────────────────────────────

  /// Increments the view counter for a specific product as a fire-and-forget background analytics request.
  static Future<void> incrementProductViews(int id) async {
    developer.log('📡 [API] Incrementing views for product $id', name: _tag);
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/products/$id'))
          .timeout(const Duration(seconds: 10));
      developer.log('📥 [API] View count incremented for product $id: status ${response.statusCode}', name: _tag);
    } catch (e) {
      // Catch silently to avoid disrupting user experience in case of connection failure or latency
      developer.log('⚠️ [API] Failed to increment views for product $id: $e', name: _tag);
    }
  }
}
