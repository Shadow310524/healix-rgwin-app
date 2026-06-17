import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Design tokens — exact match to web CSS variables
  static const Color primary = Color(0xFF008080);
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);
  static const Color surface = Color(0xFFf8fafc);
  static const Color border = Color(0xFFe2e8f0);

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      developer.log('📡 [ProductsScreen] Fetching products and categories...', name: 'ProductsScreen');
      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);
      setState(() {
        _allProducts = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
      _applyFilters();
      developer.log('✅ [ProductsScreen] Loaded ${_allProducts.length} products, ${_categories.length} categories', name: 'ProductsScreen');
    } catch (e, stack) {
      developer.log('💥 [ProductsScreen] Error: $e', name: 'ProductsScreen', error: e, stackTrace: stack);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        // web: matches search + category
        final matchesSearch = _searchQuery.isEmpty ||
            p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final catName = p.category?.name ?? 'Uncategorized';
        final matchesCategory = _selectedCategory == 'All' || catName == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Category list — matches web: ['All', ...unique category names]
    final categories = ['All', ..._categories.map((c) => c.name)];

    return Scaffold(
      backgroundColor: surface, // web: bg-[--color-surface]
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page header area — web: flex justify-between items-center mb-12
            Container(
              color: surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row — web: h1 text-3xl + search input + filter button
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Products',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Explore the Healix range of healthcare solutions.',
                              style: TextStyle(fontSize: 14, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar — web: input-field with Search icon
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.7), fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: textMuted, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: textMuted, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category pills — web: flex gap-2 overflow-x-auto
                  if (!_isLoading && _errorMessage == null)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              _applyFilters();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                // web: bg-[--color-primary] text-white OR bg-gray-100 text-gray-700
                                color: isSelected ? primary : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF374151),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Products grid
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primary),
            SizedBox(height: 16),
            Text('Loading products...', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56, color: textMuted),
              const SizedBox(height: 16),
              const Text('Unable to load products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: textMuted, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _loadData,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: textMuted),
            SizedBox(height: 16),
            Text(
              'No products found matching your search.',
              style: TextStyle(color: textMuted, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // web: grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.56,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, i) => _ProductCard(product: _filteredProducts[i]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  static const Color primary = Color(0xFF008080);
  static const Color primaryLight = Color(0xFFe6f2f2);
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);
  static const Color border = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        // web: card class = bg-white rounded-xl shadow-sm border border-gray-100 hover:shadow-2xl
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — web: h-56 rounded-t-lg overflow-hidden + overlay on hover
            Stack(
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 150,
                      color: const Color(0xFFf3f4f6),
                      child: const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 150,
                      color: const Color(0xFFf3f4f6),
                      child: const Icon(Icons.broken_image_outlined, color: textMuted, size: 36),
                    ),
                  ),
                ),
                // Dark overlay — web: bg-black/5 group-hover:bg-transparent
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.04)),
                ),
              ],
            ),

            // Card body — web: flex-grow p-5 pt-0
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category — web: text-xs font-bold text-[--color-primary] uppercase tracking-wider
                    Text(
                      (product.category?.name ?? 'Uncategorized').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primary,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Name — web: text-xl font-bold text-[--color-text-main] group-hover:text-[--color-primary]
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Description — web: text-sm text-muted line-clamp-3
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 11, color: textMuted, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Price row — web: flex items-center justify-between border-t border-gray-100
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFf3f4f6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // web: text-xl font-bold text-[--color-text-main]
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        if (product.mrp != null && product.mrp!.isNotEmpty)
                          Text(
                            product.mrp!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9ca3af),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Arrow button — web: p-2 bg-[--color-primary-light] text-primary rounded-full
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: primary, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
