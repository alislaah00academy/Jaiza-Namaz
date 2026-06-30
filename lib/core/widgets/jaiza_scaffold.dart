import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cream backdrop with a subtle Islamic-inspired geometric overlay.
/// In dark mode the pattern is nearly invisible (warm solid background).
class JaizaBackground extends StatelessWidget {
  const JaizaBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  final Widget child;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient(context),
          ),
        ),
        if (showPattern && !isDark)
          CustomPaint(
            painter: _JaizaPatternPainter(
              color: AppTokens.lightOnSurfaceVariant.withValues(alpha: 0.06),
            ),
          ),
        child,
      ],
    );
  }
}

class _JaizaPatternPainter extends CustomPainter {
  _JaizaPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const step = 48.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), 10, paint);
      }
    }

    // Soft diagonal weave
    final weave = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    for (double i = -size.height; i < size.width + size.height; i += 64) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        weave,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final rad = i.isEven ? r : r * 0.45;
      final px = c.dx + rad * math.cos(angle);
      final py = c.dy + rad * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JaizaPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Elevated rounded surface for forms and grouped content (reference card look).
class JaizaSurfaceCard extends StatelessWidget {
  const JaizaSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppTokens.radiusCard);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        boxShadow: AppTokens.softShadow(context),
        border: Border.all(color: c.outline.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
