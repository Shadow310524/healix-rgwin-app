import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../utils/app_colors.dart';
import 'contact_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Parse once at build time — not repeated on every rebuild
    final benefits = _parseList(product.benefits);
    final ingredients = _parseList(product.ingredients);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _ProductAppBar(product: product),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBadge(name: product.category?.name),
                      const SizedBox(height: 16),
                      _ProductTitle(name: product.name),
                      const SizedBox(height: 8),
                      _PriceRow(price: product.price, mrp: product.mrp),
                      const SizedBox(height: 16),
                      _Description(text: product.description),
                      const SizedBox(height: 24),
                      const _TrustBadgeRow(),
                      const SizedBox(height: 24),
                      if (benefits.isNotEmpty) _BenefitsList(benefits: benefits),
                      if (ingredients.isNotEmpty) _IngredientChips(ingredients: ingredients),
                      const SizedBox(height: 80), // space for sticky button
                    ],
                  ),
                ),
              ),
            ],
          ),
          _EnquireButton(product: product),
        ],
      ),
    );
  }

  /// Splits a comma-separated string into a trimmed, non-empty list.
  static List<String> _parseList(String raw) =>
      raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _ProductAppBar extends StatelessWidget {
  final Product product;
  const _ProductAppBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: ColoredBox(
              color: const Color(0x4D000000),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product.id}',
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(
              color: AppColors.gray100,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            errorWidget: (_, __, ___) => const ColoredBox(
              color: AppColors.gray100,
              child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detail Body Widgets ──────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String? name;
  const _CategoryBadge({this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Text(
        (name ?? 'Uncategorized').toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ProductTitle extends StatelessWidget {
  final String name;
  const _ProductTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
        letterSpacing: -0.5,
        height: 1.2,
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String price;
  final String? mrp;
  const _PriceRow({required this.price, this.mrp});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        if (mrp != null && mrp!.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(
            mrp!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6b7280),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _Description extends StatelessWidget {
  final String text;
  const _Description({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: AppColors.textMuted, height: 1.6),
    );
  }
}

class _TrustBadgeRow extends StatelessWidget {
  const _TrustBadgeRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _TrustBadge(icon: Icons.verified_user_outlined, label: 'Clinically Tested')),
        SizedBox(width: 12),
        Expanded(child: _TrustBadge(icon: Icons.show_chart_rounded, label: 'High Efficacy')),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMain),
          ),
        ),
      ],
    );
  }
}

class _BenefitsList extends StatelessWidget {
  final List<String> benefits;
  const _BenefitsList({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Benefits',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 10),
        ...benefits.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: CircleAvatar(radius: 3, backgroundColor: AppColors.textMuted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(b, style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _IngredientChips extends StatelessWidget {
  final List<String> ingredients;
  const _IngredientChips({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Ingredients',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ingredients
              .map((ing) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(ing, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Sticky Enquire Button ────────────────────────────────────────────────────

class _EnquireButton extends StatelessWidget {
  final Product product;
  const _EnquireButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -4))],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: const Text('Enquire Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactScreen(productName: product.name)),
          ),
        ),
      ),
    );
  }
}
