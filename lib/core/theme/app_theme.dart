import 'package:flutter/material.dart';

/// Islamic-inspired green + white theme with soft contrast.
abstract final class AppTheme {
  static const Color seedGreen = Color(0xFF0F766E);
  static const Color accentLight = Color(0xFFCCFBF1);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedGreen,
      brightness: Brightness.light,
      primary: const Color(0xFF0D9488),
      surface: Colors.white,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerLowest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Header gradient used on home / splash accents.
  static LinearGradient primaryGradient(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return LinearGradient(
      colors: [
        c.primary.withValues(alpha: 0.15),
        c.primaryContainer.withValues(alpha: 0.35),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
