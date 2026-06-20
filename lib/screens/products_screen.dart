import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/app_colors.dart';
import '../widgets/shimmer_loading.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      developer.log('📡 Fetching products and categories...', name: 'ProductsScreen');
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
    if (_selectedCategory == cat) return;
    setState(() => _selectedCategory = cat);
    _applyFilters();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final categories = ['All', ..._categories.map((c) => c.name)];

    return Scaffold(
      backgroundColor: colors.surface,
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
            Expanded(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_isLoading && _allProducts.isEmpty) {
      return const ProductsShimmer();
    }
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: () => _loadData(forceRefresh: true));
    }
    
    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () => _loadData(forceRefresh: true),
      child: _filteredProducts.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: const _EmptyState(),
              ),
            )
          : _ProductGrid(products: _filteredProducts),
    );
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
    final colors = context.colors;
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 20.0;
    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
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
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Products',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Explore the Healix range of healthcare solutions.',
          style: TextStyle(fontSize: 14, color: colors.textMuted),
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
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: colors.textMain),
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: Icon(Icons.search, color: colors.textMuted, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, size: 18, color: colors.textMuted),
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
    final colors = context.colors;
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
                color: isSelected ? colors.primary : colors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.gray700,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: colors.textMuted),
            const SizedBox(height: 16),
            Text('Unable to load products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textMain)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: colors.textMuted, fontSize: 13), textAlign: TextAlign.center),
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
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No products found matching your search.',
            style: TextStyle(color: colors.textMuted, fontSize: 15),
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
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 700;
    final hPad = w < 360 ? 16.0 : 24.0;

    if (isMobile) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, i) {
          return TweenAnimationBuilder<double>(
            key: ValueKey(products[i].id),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (i * 100).clamp(0, 400)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: RepaintBoundary(
              child: IntrinsicHeight(
                child: _ProductCard(product: products[i]),
              ),
            ),
          );
        },
      );
    }

    // Tablet/Desktop grid
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(products[i].id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (i * 100).clamp(0, 400)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: RepaintBoundary(child: _ProductCard(product: products[i])),
        );
      },
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Future.delayed(const Duration(milliseconds: 60), () {
          if (!mounted) return;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProductDetailsScreen(product: widget.product),
              transitionsBuilder: (_, animation, __, child) {
                var tween = Tween(begin: const Offset(0.0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          );
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardImage(product: widget.product),
              _CardBody(product: widget.product),
              _CardFooter(product: widget.product),
            ],
          ),
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
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.gray100,
      highlightColor: colors.surface,
      child: Container(
        height: 150,
        color: Colors.white,
      ),
    );
  }
}

class _CardImageError extends StatelessWidget {
  const _CardImageError();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 150,
      color: colors.gray100,
      child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: 36),
    );
  }
}

class _CardBody extends StatelessWidget {
  final Product product;
  const _CardBody({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF0A2540), width: 2)),
            ),
            child: Text(
              (product.category?.name ?? 'Uncategorized').toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2540),
                letterSpacing: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0A2540), height: 1.1, letterSpacing: -0.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (product.ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(Icons.science_outlined, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE COMPOSITION',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    product.ingredients.first,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
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
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2540),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'VIEW CLINICAL PROFILE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
