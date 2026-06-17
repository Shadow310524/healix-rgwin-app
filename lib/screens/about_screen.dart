import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: colors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: colors.primaryLight),
                    errorWidget: (context, url, error) => Container(color: colors.primaryLight),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, colors.background],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                'About RG WIN HEALTHCARE',
                style: TextStyle(
                  color: colors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  "Pioneering advancements in women's health through innovative gynecological solutions.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                _SectionTitle(title: 'Our Vision', color: colors.primary),
                const SizedBox(height: 12),
                Text(
                  'We envision a world where women have access to the highest standard of specialized healthcare. '
                  'Through rigorous research and clinical excellence, Healix stands at the forefront of gynecological medicine, empowering women at every stage of their lives.',
                  style: TextStyle(fontSize: 16, color: colors.textMuted, height: 1.6),
                ),
                const SizedBox(height: 32),
                _SectionTitle(title: 'Commitment to Quality', color: colors.secondary),
                const SizedBox(height: 16),
                const _QualityItem('Stringent clinical testing protocols.'),
                const SizedBox(height: 12),
                const _QualityItem('State-of-the-art manufacturing facilities.'),
                const SizedBox(height: 12),
                const _QualityItem('Continuous investment in research and development.'),
                const SizedBox(height: 12),
                const _QualityItem('Collaboration with leading medical professionals.'),
                const SizedBox(height: 32),
                const _StatsRow(),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textMain,
          ),
        ),
      ],
    );
  }
}

class _QualityItem extends StatelessWidget {
  final String text;

  const _QualityItem(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: colors.textMuted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatefulWidget {
  const _StatsRow();

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _productsAnim;
  late Animation<int> _yearsAnim;
  late Animation<int> _hcpAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _productsAnim = IntTween(begin: 0, end: 500).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _yearsAnim = IntTween(begin: 0, end: 10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _hcpAnim = IntTween(begin: 0, end: 1000).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    // Start animation when widget is built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: [
            _StatBox(value: '${_productsAnim.value}+', label: 'Products'),
            const SizedBox(width: 16),
            _StatBox(value: '${_yearsAnim.value}+', label: 'Years'),
            const SizedBox(width: 16),
            _StatBox(value: '${_hcpAnim.value}+', label: 'HCPs'),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
