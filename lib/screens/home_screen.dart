import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  // Design tokens — exact match to web CSS variables
  static const Color primary = Color(0xFF008080);
  static const Color primaryDark = Color(0xFF006666);
  static const Color primaryLight = Color(0xFFe6f2f2);
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Navbar — matching web: white bg, pill icon, "Healix" bold
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            scrolledUnderElevation: 1,
            shadowColor: const Color(0xFFe2e8f0),
            title: Row(
              children: [
                const Icon(Icons.medication_rounded, color: primary, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Healix',
                  style: TextStyle(
                    color: primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section — web: bg-[--color-primary-light] h-[90vh] gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFe6f2f2), Color(0xFFdceaf7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline — web: text-5xl md:text-7xl font-extrabold
                      const Text(
                        "Advancing Women's",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: textMain,
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [primary, Color(0xFF14b8a6)],
                        ).createShader(bounds),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // CTA Buttons — web: btn-primary + btn-secondary
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () => onNavigate?.call(1),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('View Products', style: TextStyle(fontWeight: FontWeight.w600)),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                                side: const BorderSide(color: primary),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => onNavigate?.call(2),
                              child: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hero image — web: medical professional photo
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 240,
                    color: primaryLight,
                    child: const Center(child: CircularProgressIndicator(color: primary)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 240,
                    color: primaryLight,
                    child: const Icon(Icons.medication_rounded, color: primary, size: 64),
                  ),
                ),

                // "Why Choose Healix" Section — web: py-24 bg-white
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
                  child: Column(
                    children: [
                      const Text(
                        'Why Choose Healix',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We are committed to delivering high-quality, safe, and effective healthcare solutions specifically tailored for women.',
                        style: TextStyle(fontSize: 15, color: textMuted, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Feature cards — web: grid grid-cols-3 gap-10
                      _FeatureCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Clinically Proven',
                        desc: 'All our products undergo rigorous clinical testing to ensure maximum efficacy and safety.',
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        icon: Icons.biotech_outlined,
                        title: 'Modern Research',
                        desc: 'Developed using the latest advancements in gynecological and pharmaceutical sciences.',
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        icon: Icons.favorite_border_rounded,
                        title: 'Patient Centric',
                        desc: 'Designed with the comfort, well-being, and specific needs of women in mind.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge — web: w-20 h-20 bg-gradient rounded-2xl rotate-3
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe6f2f2), Color(0xFFdbeafe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: const Color(0xFF008080), size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748b),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
