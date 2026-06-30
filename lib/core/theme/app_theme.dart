import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm Islamic UI Kit inspired tokens (gold + ivory + bronze).
abstract final class AppTokens {
  // Light
  static const Color lightBackground = Color(0xFFFBF3E3);
  static const Color lightSurfaceVariant = Color(0xFFF2E4C4);
  static const Color lightSurface = Color(0xFFFFFDF7);
  static const Color lightPrimary = Color(0xFFB8863C);
  static const Color lightPrimaryContainer = Color(0xFFF3E6C8);
  static const Color lightSecondary = Color(0xFF8B6F47);
  static const Color lightSecondaryContainer = Color(0xFFF6EFE0);
  static const Color lightAccentGold = Color(0xFFC9A227);
  static const Color lightOnBackground = Color(0xFF3A2A1C);
  static const Color lightOnSurfaceVariant = Color(0xFF7C6A4F);
  static const Color lightOutline = Color(0xFFE3D2AE);

  // Dark (warm complementary)
  static const Color darkBackground = Color(0xFF1F1B16);
  static const Color darkSurface = Color(0xFF2A2521);
  static const Color darkSurfaceVariant = Color(0xFF3A332C);
  static const Color darkPrimary = Color(0xFFD9B36C);
  static const Color darkPrimaryContainer = Color(0xFF4A3B22);
  static const Color darkSecondary = Color(0xFFD4B58F);
  static const Color darkSecondaryContainer = Color(0xFF4A3F35);
  static const Color darkOnBackground = Color(0xFFEFE3CC);
  static const Color darkOnSurfaceVariant = Color(0xFFB8A892);
  static const Color darkOutline = Color(0xFF6B6158);

  static const double radiusCard = 24;
  static const double radiusButton = 18;
  static const double radiusInput = 16;
  static const double radiusChip = 20;

  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

/// Islamic-inspired cream + sage theme with full Material 3 component tuning.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppTokens.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppTokens.lightPrimaryContainer,
      onPrimaryContainer: AppTokens.lightOnBackground,
      secondary: AppTokens.lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppTokens.lightSecondaryContainer,
      onSecondaryContainer: AppTokens.lightOnBackground,
      tertiary: AppTokens.lightAccentGold,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF5EAD8),
      onTertiaryContainer: AppTokens.lightOnBackground,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: AppTokens.lightSurface,
      onSurface: AppTokens.lightOnBackground,
      surfaceContainerHighest: AppTokens.lightSurfaceVariant,
      surfaceContainerHigh: Color(0xFFF5EFE6),
      surfaceContainer: Color(0xFFF3EDE4),
      surfaceContainerLow: Color(0xFFF8F4EE),
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: AppTokens.lightOnSurfaceVariant,
      outline: AppTokens.lightOutline,
      outlineVariant: Color(0xFFE5D9CC),
      shadow: Colors.black26,
      scrim: Colors.black54,
      inverseSurface: AppTokens.darkSurface,
      onInverseSurface: AppTokens.darkOnBackground,
      inversePrimary: AppTokens.darkPrimary,
    );

    final baseText = TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
    );

    final textTheme = _withDisplayFont(GoogleFonts.poppinsTextTheme(baseText));

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.lightBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        constraints: const BoxConstraints(minHeight: 58),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle:
            textTheme.titleSmall?.copyWith(color: scheme.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusButton),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(AppTokens.radiusCard),
            bottomRight: Radius.circular(AppTokens.radiusCard),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: scheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppTokens.darkPrimary,
      onPrimary: Color(0xFF0D1F1A),
      primaryContainer: AppTokens.darkPrimaryContainer,
      onPrimaryContainer: AppTokens.darkOnBackground,
      secondary: AppTokens.darkSecondary,
      onSecondary: Color(0xFF2A2218),
      secondaryContainer: AppTokens.darkSecondaryContainer,
      onSecondaryContainer: AppTokens.darkOnBackground,
      tertiary: Color(0xFFE8C98A),
      onTertiary: Color(0xFF2A2218),
      tertiaryContainer: Color(0xFF5C4D38),
      onTertiaryContainer: AppTokens.darkOnBackground,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: AppTokens.darkSurface,
      onSurface: AppTokens.darkOnBackground,
      surfaceContainerHighest: AppTokens.darkSurfaceVariant,
      surfaceContainerHigh: Color(0xFF332E29),
      surfaceContainer: Color(0xFF2E2925),
      surfaceContainerLow: Color(0xFF25221E),
      surfaceContainerLowest: Color(0xFF1C1916),
      onSurfaceVariant: AppTokens.darkOnSurfaceVariant,
      outline: AppTokens.darkOutline,
      outlineVariant: Color(0xFF524840),
      shadow: Colors.black54,
      scrim: Colors.black87,
      inverseSurface: AppTokens.lightSurface,
      onInverseSurface: AppTokens.lightOnBackground,
      inversePrimary: AppTokens.lightPrimary,
    );

    final baseText = TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: scheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
    );

    final textTheme = _withDisplayFont(GoogleFonts.poppinsTextTheme(baseText));

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        constraints: const BoxConstraints(minHeight: 58),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle:
            textTheme.titleSmall?.copyWith(color: scheme.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusButton),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(AppTokens.radiusCard),
            bottomRight: Radius.circular(AppTokens.radiusCard),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: scheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  /// Hero area gradient (cream warmth).
  static LinearGradient heroGradient(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [
              c.surfaceContainerHighest.withValues(alpha: 0.9),
              c.surface.withValues(alpha: 0.95),
            ]
          : [
              AppTokens.lightSurfaceVariant.withValues(alpha: 0.95),
              AppTokens.lightSurface.withValues(alpha: 0.98),
              AppTokens.lightBackground,
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Legacy alias used by some screens — soft sage/teal wash.
  static LinearGradient primaryGradient(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return LinearGradient(
      colors: [
        c.primary.withValues(alpha: 0.12),
        c.secondary.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Soft shadow list for elevated cards (use with DecoratedBox).
  static List<BoxShadow> softShadow(BuildContext context) =>
      AppTokens.softShadow(context);

  /// Layers the elegant serif (Playfair Display) over display/headline/title
  /// styles only; body/label text stays on Poppins for readability.
  static TextTheme _withDisplayFont(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(textStyle: base.displayLarge),
      displayMedium:
          GoogleFonts.playfairDisplay(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.playfairDisplay(textStyle: base.displaySmall),
      headlineLarge:
          GoogleFonts.playfairDisplay(textStyle: base.headlineLarge),
      headlineMedium:
          GoogleFonts.playfairDisplay(textStyle: base.headlineMedium),
      headlineSmall:
          GoogleFonts.playfairDisplay(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.playfairDisplay(textStyle: base.titleLarge),
    );
  }

  /// FilledButton.tonal style for tan secondary actions.
  static ButtonStyle tonalButtonStyle(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      foregroundColor: c.onSecondaryContainer,
      backgroundColor: c.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusButton),
      ),
    );
  }
}
