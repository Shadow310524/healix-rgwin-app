import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';

class ProductsShimmer extends StatelessWidget {
  const ProductsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final w = MediaQuery.sizeOf(context).width;
    final crossAxisCount = w < 340 ? 1 : w < 600 ? 2 : 3;
    final aspectRatio = w < 340 ? 0.72 : 0.56;
    final hPad = w < 360 ? 12.0 : 20.0;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: colors.gray100,
        highlightColor: colors.surface,
        child: Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 150, color: Colors.white),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(height: 12, width: 80, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(height: 16, width: double.infinity, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(height: 16, width: 120, color: Colors.white),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Container(height: 20, width: 60, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
