import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textMain;
  final Color textMuted;
  final Color border;
  final Color success;
  final Color error;
  final Color gray100;
  final Color gray400;
  final Color gray700;
  final LinearGradient heroGradient;
  final LinearGradient primaryGradient;
  final LinearGradient iconGradient;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textMain,
    required this.textMuted,
    required this.border,
    required this.success,
    required this.error,
    required this.gray100,
    required this.gray400,
    required this.gray700,
    required this.heroGradient,
    required this.primaryGradient,
    required this.iconGradient,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textMain,
    Color? textMuted,
    Color? border,
    Color? success,
    Color? error,
    Color? gray100,
    Color? gray400,
    Color? gray700,
    LinearGradient? heroGradient,
    LinearGradient? primaryGradient,
    LinearGradient? iconGradient,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textMain: textMain ?? this.textMain,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      success: success ?? this.success,
      error: error ?? this.error,
      gray100: gray100 ?? this.gray100,
      gray400: gray400 ?? this.gray400,
      gray700: gray700 ?? this.gray700,
      heroGradient: heroGradient ?? this.heroGradient,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      iconGradient: iconGradient ?? this.iconGradient,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
      gray700: Color.lerp(gray700, other.gray700, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      iconGradient: LinearGradient.lerp(iconGradient, other.iconGradient, t)!,
    );
  }

  static const light = AppColors(
    primary: Color(0xFF008080),
    primaryDark: Color(0xFF006666),
    primaryLight: Color(0xFFe6f2f2),
    secondary: Color(0xFF005c99),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFf8fafc),
    textMain: Color(0xFF1e293b),
    textMuted: Color(0xFF64748b),
    border: Color(0xFFe2e8f0),
    success: Color(0xFF16a34a),
    error: Color(0xFFdc2626),
    gray100: Color(0xFFf3f4f6),
    gray400: Color(0xFF9ca3af),
    gray700: Color(0xFF374151),
    heroGradient: LinearGradient(
      colors: [Color(0xFFe6f2f2), Color(0xFFdceaf7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF008080), Color(0xFF14b8a6)],
    ),
    iconGradient: LinearGradient(
      colors: [Color(0xFFe6f2f2), Color(0xFFdbeafe)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const dark = AppColors(
    primary: Color(0xFF2DD4BF),
    primaryDark: Color(0xFF14B8A6),
    primaryLight: Color(0xFF115E59),
    secondary: Color(0xFF38BDF8),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textMain: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    success: Color(0xFF4ADE80),
    error: Color(0xFFF87171),
    gray100: Color(0xFF1E293B),
    gray400: Color(0xFF64748B),
    gray700: Color(0xFFCBD5E1),
    heroGradient: LinearGradient(
      colors: [Color(0xFF115E59), Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
    ),
    iconGradient: LinearGradient(
      colors: [Color(0xFF115E59), Color(0xFF1E3A8A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
