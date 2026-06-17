import 'package:flutter/material.dart';

/// Single source of truth for ALL design tokens.
/// Mirrors the web platform's CSS variables exactly.
/// Used across every screen — never repeat Color() values in widgets.
abstract final class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF008080);
  static const Color primaryDark = Color(0xFF006666);
  static const Color primaryLight = Color(0xFFe6f2f2);

  // Secondary
  static const Color secondary = Color(0xFF005c99);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFf8fafc);

  // Text
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);

  // Borders
  static const Color border = Color(0xFFe2e8f0);

  // Utility
  static const Color success = Color(0xFF16a34a);
  static const Color error = Color(0xFFdc2626);
  static const Color gray100 = Color(0xFFf3f4f6);
  static const Color gray400 = Color(0xFF9ca3af);
  static const Color gray700 = Color(0xFF374151);

  // Gradient stops (hero, feature icons)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryLight, Color(0xFFdceaf7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF14b8a6)],
  );

  static const LinearGradient iconGradient = LinearGradient(
    colors: [primaryLight, Color(0xFFdbeafe)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
