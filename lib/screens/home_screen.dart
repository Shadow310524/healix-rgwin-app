import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Navbar — white bg, pill icon, "Healix" bold (matches web Navbar.jsx)
          const SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.border,
            title: _NavbarTitle(),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(onNavigate: onNavigate),
                _HeroImage(),
                const _WhyChooseSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navbar ──────────────────────────────────────────────────────────────────

class _NavbarTitle extends StatelessWidget {
  const _NavbarTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.medication_rounded, color: AppColors.primary, size: 28),
        SizedBox(width: 8),
        Text(
          'Healix',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}

// ─── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final void Function(int)? onNavigate;
  const _HeroSection({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient headline — matches web ShaderMask text
          const Text(
            "Advancing Women's",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Health Innovation',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover our specialized range of gynecological pharmaceutical products designed for modern healthcare needs.',
            style: TextStyle(fontSize: 16, color: AppColors.textMuted, height: 1.6),
          ),
          const SizedBox(height: 28),
          _HeroCTAs(onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _HeroCTAs extends StatelessWidget {
  final void Function(int)? onNavigate;
  const _HeroCTAs({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onNavigate?.call(1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View Products'),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => onNavigate?.call(2),
            child: const Text('Contact Us'),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  static const _url =
      'https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _url,
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _ImagePlaceholder(),
      errorWidget: (_, __, ___) => const _ImageError(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      color: AppColors.primaryLight,
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      color: AppColors.primaryLight,
      child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 64),
    );
  }
}

// ─── "Why Choose Healix" Section ─────────────────────────────────────────────

class _WhyChooseSection extends StatelessWidget {
  const _WhyChooseSection();

  static const _features = [
    (Icons.verified_user_outlined, 'Clinically Proven',
        'All our products undergo rigorous clinical testing to ensure maximum efficacy and safety.'),
    (Icons.biotech_outlined, 'Modern Research',
        'Developed using the latest advancements in gynecological and pharmaceutical sciences.'),
    (Icons.favorite_border_rounded, 'Patient Centric',
        'Designed with the comfort, well-being, and specific needs of women in mind.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        children: [
          const Text(
            'Why Choose Healix',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'We are committed to delivering high-quality, safe, and effective healthcare solutions specifically tailored for women.',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Build feature cards from static list — no repeated widget code
          for (int i = 0; i < _features.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _FeatureCard(
              icon: _features[i].$1,
              title: _features[i].$2,
              desc: _features[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.iconGradient,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
