import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import 'contact_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  // Design tokens — exact match to web CSS variables
  static const Color primary = Color(0xFF008080);
  static const Color primaryLight = Color(0xFFe6f2f2);
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);
  static const Color border = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    // web: Parse strings into arrays if they exist
    final benefits = product.benefits.isNotEmpty
        ? product.benefits.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toList()
        : <String>[];
    final ingredients = product.ingredients.isNotEmpty
        ? product.ingredients.split(',').map((i) => i.trim()).where((i) => i.isNotEmpty).toList()
        : <String>[];

    return Scaffold(
      backgroundColor: Colors.white, // web: bg-white
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SliverAppBar with glassmorphic back button like web's ArrowLeft back link
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
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
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFf9fafb),
                        child: const Center(child: CircularProgressIndicator(color: primary)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFf9fafb),
                        child: const Icon(Icons.broken_image_outlined, color: textMuted, size: 64),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  // web: max-w-7xl mx-auto px-4 sm:px-6 lg:px-8
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill — web: inline-block px-3 py-1 bg-[--color-primary-light] rounded-full uppercase tracking-wider
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (product.category?.name ?? 'Uncategorized').toUpperCase(),
                          style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product name — web: text-4xl font-bold text-[--color-text-main]
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price row — web: text-3xl font-bold text-[--color-primary] + line-through mrp
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          if (product.mrp != null && product.mrp!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Text(
                              product.mrp!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6b7280),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description — web: text-lg text-[--color-text-muted] mb-8 leading-relaxed
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Trust badges — web: grid grid-cols-2 gap-4 mb-8
                      Row(
                        children: [
                          Expanded(child: _TrustBadge(icon: Icons.verified_user_outlined, label: 'Clinically Tested')),
                          const SizedBox(width: 12),
                          Expanded(child: _TrustBadge(icon: Icons.show_chart_rounded, label: 'High Efficacy')),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Key Benefits — web: h3 font-bold + ul list-disc
                      if (benefits.isNotEmpty) ...[
                        const Text(
                          'Key Benefits',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...benefits.map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: CircleAvatar(
                                      radius: 3,
                                      backgroundColor: textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(b, style: const TextStyle(fontSize: 15, color: textMuted, height: 1.4)),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // Active Ingredients — web: flex flex-wrap gap-2 + pill chips bg-gray-100
                      if (ingredients.isNotEmpty) ...[
                        const Text(
                          'Active Ingredients',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ingredients
                              .map((ing) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      // web: px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm
                                      color: const Color(0xFFf3f4f6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      ing,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Bottom padding for the sticky button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Enquire Now — sticky bottom button matching web: btn-primary w-full md:w-auto py-3 text-lg
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Enquire Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactScreen(productName: product.name)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Trust badge widget — web: w-10 h-10 rounded-full bg-[--color-primary-light] flex items-center justify-center
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
          decoration: const BoxDecoration(
            color: Color(0xFFe6f2f2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF008080), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1e293b),
            ),
          ),
        ),
      ],
    );
  }
}
