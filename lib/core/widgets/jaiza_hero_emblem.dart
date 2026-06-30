import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular elevated “hero” block mimicking the reference’s 3D mosque tile.
class JaizaHeroEmblem extends StatelessWidget {
  const JaizaHeroEmblem({
    super.key,
    this.size = 112,
    this.icon = Icons.mosque_rounded,
    this.iconSize = 52,
  });

  final double size;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [
                  c.surfaceContainerHighest,
                  c.surface,
                ]
              : [
                  Colors.white,
                  c.secondaryContainer.withValues(alpha: 0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTokens.softShadow(context),
        border: Border.all(
          color: c.outline.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: c.primary,
      ),
    );
  }
}
