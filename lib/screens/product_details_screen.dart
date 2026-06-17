import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for HapticFeedback
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import '../models/product.dart';
import '../utils/app_colors.dart';
import 'contact_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Parse once at build time — not repeated on every rebuild
    final benefits = _parseList(product.benefits);
    final ingredients = _parseList(product.ingredients);

    return Scaffold(
      backgroundColor: colors.background,
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
    final colors = context.colors;
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: colors.background,
      surfaceTintColor: colors.background,
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
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: ColoredBox(
                color: const Color(0x4D000000),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // ignore: deprecated_member_use
                    Share.share(
                      'Check out ${product.name} from Healix Healthcare!\n\nhttps://healix-rgwin.onrender.com/products/${product.id}',
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black.withAlpha(230),
                pageBuilder: (BuildContext context, _, __) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                    body: Center(
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: _FullScreenImageViewer(imageUrl: product.imageUrl),
                      ),
                    ),
                  );
                },
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Hero(
            tag: 'product-${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => ColoredBox(
                color: colors.gray100,
                child: Center(child: CircularProgressIndicator(color: colors.primary)),
              ),
              errorWidget: (_, __, ___) => ColoredBox(
                color: colors.gray100,
                child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: CachedNetworkImageProvider(imageUrl),
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
    );
  }
}

// ─── Detail Body Widgets ──────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String? name;
  const _CategoryBadge({this.name});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryLight,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Text(
        (name ?? 'Uncategorized').toUpperCase(),
        style: TextStyle(
          color: colors.primary,
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
    final colors = context.colors;
    return Text(
      name,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.textMain,
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
    final colors = context.colors;
    return Builder(
      builder: (context) {
        double? priceValue;
        double? mrpValue;
        try {
          priceValue = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
          mrpValue = double.tryParse(mrp?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '');
        } catch (_) {}

        int? discountPercent;
        if (priceValue != null && mrpValue != null && mrpValue > priceValue && mrpValue > 0) {
          discountPercent = ((mrpValue - priceValue) / mrpValue * 100).round();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            if (mrp != null && mrp!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'MRP: $mrp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
            if (discountPercent != null && discountPercent > 0) ...[
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$discountPercent% OFF',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Description extends StatelessWidget {
  final String text;
  const _Description({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: colors.textMuted, height: 1.6),
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
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: colors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textMain),
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
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Benefits',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textMain)),
        const SizedBox(height: 10),
        ...benefits.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: CircleAvatar(radius: 3, backgroundColor: colors.textMuted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(b, style: TextStyle(fontSize: 15, color: colors.textMuted, height: 1.4)),
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
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Ingredients',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textMain)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ingredients
              .map((ing) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.gray100,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(ing, style: TextStyle(fontSize: 13, color: colors.gray700)),
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
    final colors = context.colors;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.border)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -4))],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: const Text('Enquire Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ContactScreen(productName: product.name),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
