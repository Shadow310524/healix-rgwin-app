import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';
import '../main.dart'; // for themeNotifier
import '../widgets/ai_assistant_fab.dart';
import 'chat_screen.dart';

import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: AiAssistantFab(onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
      }),
      body: CustomScrollView(
        slivers: [
          // Navbar
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.background,
            surfaceTintColor: colors.background,
            scrolledUnderElevation: 1,
            shadowColor: colors.border,
            title: const _NavbarTitle(),
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: colors.textMain,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  themeNotifier.toggleTheme();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(onNavigate: onNavigate),
                const _HeroImage(),
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
    final colors = context.colors;
    return Row(
      children: [
        Icon(Icons.medication_rounded, color: colors.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          'Healix',
          style: TextStyle(
            color: colors.primaryDark,
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
    final colors = context.colors;
    final w = MediaQuery.sizeOf(context).width;
    // Responsive font: 28 on tiny phones, 32 on small, 36 on normal+
    final heroFont = w < 340 ? 26.0 : w < 380 ? 30.0 : 36.0;
    final bodyFont = w < 340 ? 14.0 : 16.0;
    final hPad = w < 360 ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 40),
      decoration: BoxDecoration(gradient: colors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient headline — matches web ShaderMask text
          Text(
            "Advancing Women's",
            style: TextStyle(
              fontSize: heroFont,
              fontWeight: FontWeight.w900,
              color: colors.textMain,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => colors.primaryGradient.createShader(bounds),
            child: Text(
              'Health Innovation',
              style: TextStyle(
                fontSize: heroFont,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Discover our specialized range of gynecological pharmaceutical products designed for modern healthcare needs.',
            style: TextStyle(fontSize: bodyFont, color: colors.textMuted, height: 1.6),
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
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Products'),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => onNavigate?.call(2), // 2 is Contact Us (0 Home, 1 Prod, 2 Contact, 3 About)
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Contact Us'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage();

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
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.gray100,
      highlightColor: colors.surface,
      child: Container(
        height: 240,
        color: Colors.white,
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 240,
      color: colors.primaryLight,
      child: Icon(Icons.medication_rounded, color: colors.primary, size: 64),
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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        children: [
          Text(
            'Why Choose Healix',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textMain,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We are committed to delivering high-quality, safe, and effective healthcare solutions specifically tailored for women.',
            style: TextStyle(fontSize: 15, color: colors.textMuted, height: 1.5),
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
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
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
            decoration: BoxDecoration(
              gradient: colors.iconGradient,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: colors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textMain)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(fontSize: 14, color: colors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
