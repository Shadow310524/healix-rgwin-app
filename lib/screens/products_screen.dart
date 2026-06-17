import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/app_colors.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

/// AutomaticKeepAliveClientMixin prevents the screen from being disposed
/// when switching tabs — the data and scroll position are preserved.
class _ProductsScreenState extends State<ProductsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      developer.log('📡 Fetching products and categories...', name: 'ProductsScreen');
      // Parallel fetch — both requests fire simultaneously
      final results = await Future.wait([
        ApiService.getProducts(forceRefresh: forceRefresh),
        ApiService.getCategories(forceRefresh: forceRefresh),
      ]);
      if (!mounted) return;
      setState(() {
        _allProducts = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
      _applyFilters();
      developer.log('✅ Loaded ${_allProducts.length} products, ${_categories.length} categories', name: 'ProductsScreen');
    } catch (e, stack) {
      developer.log('💥 Error: $e', name: 'ProductsScreen', error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesSearch = query.isEmpty || p.name.toLowerCase().contains(query);
        final catName = p.category?.name ?? 'Uncategorized';
        final matchesCat = _selectedCategory == 'All' || catName == _selectedCategory;
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  void _onCategoryTap(String cat) {
    if (_selectedCategory == cat) return; // no-op if already selected
    setState(() => _selectedCategory = cat);
    _applyFilters();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final categories = ['All', ..._categories.map((c) => c.name)];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductsHeader(
              searchController: _searchController,
              searchQuery: _searchQuery,
              categories: categories,
              selectedCategory: _selectedCategory,
              isLoading: _isLoading,
              hasError: _errorMessage != null,
              onSearchChanged: _onSearchChanged,
              onCategoryTap: _onCategoryTap,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingState();
    }
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: () => _loadData(forceRefresh: true));
    }
    if (_filteredProducts.isEmpty) {
      return const _EmptyState();
    }
    return _ProductGrid(products: _filteredProducts);
  }
}

// ─── Header (search + category pills) ─────────────────────────────────────────

class _ProductsHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final List<String> categories;
  final String selectedCategory;
  final bool isLoading;
  final bool hasError;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryTap;

  const _ProductsHeader({
    required this.searchController,
    required this.searchQuery,
    required this.categories,
    required this.selectedCategory,
    required this.isLoading,
    required this.hasError,
    required this.onSearchChanged,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageTitle(),
            const SizedBox(height: 16),
            _SearchBar(
              controller: searchController,
              query: searchQuery,
              onChanged: onSearchChanged,
            ),
            if (!isLoading && !hasError) ...[
              const SizedBox(height: 14),
              _CategoryPills(
                categories: categories,
                selected: selectedCategory,
                onTap: onCategoryTap,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Products',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Explore the Healix range of healthcare solutions.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

class _CategoryPills extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onTap;

  const _CategoryPills({required this.categories, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = selected == cat;
          return GestureDetector(
            onTap: () => onTap(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.gray700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Body states ──────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading products...', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Unable to load products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No products found matching your search.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.56,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      // RepaintBoundary isolates each card's paint — prevents full grid repaint
      // when only one card updates
      itemBuilder: (_, i) => RepaintBoundary(child: _ProductCard(product: products[i])),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(product: product),
            Expanded(child: _CardBody(product: product)),
            _CardFooter(product: product),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final Product product;
  const _CardImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'product-${product.id}',
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => const _CardImagePlaceholder(),
            errorWidget: (_, __, ___) => const _CardImageError(),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x0A000000)),
          ),
        ),
      ],
    );
  }
}

class _CardImagePlaceholder extends StatelessWidget {
  const _CardImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: AppColors.gray100,
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
    );
  }
}

class _CardImageError extends StatelessWidget {
  const _CardImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: AppColors.gray100,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 36),
    );
  }
}

class _CardBody extends StatelessWidget {
  final Product product;
  const _CardBody({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (product.category?.name ?? 'Uncategorized').toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            product.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            product.description,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final Product product;
  const _CardFooter({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                if (product.mrp != null && product.mrp!.isNotEmpty)
                  Text(
                    product.mrp!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          const _ArrowButton(),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
      ),
    );
  }
}
