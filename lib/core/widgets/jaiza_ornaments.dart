import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact arch + wordmark header with an optional back button overlay,
/// shared by auth screens (Login, Signup, Reset Password, Verify Email) so
/// they all open with the same immersive look as Welcome/Get Started
/// instead of a plain AppBar.
class JaizaAuthHeader extends StatelessWidget {
  const JaizaAuthHeader({super.key, this.onBack, this.height = 200});

  /// Null hides the back button (e.g. the email-verification gate, which
  /// has no previous auth screen to return to).
  final VoidCallback? onBack;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        JaizaArchCrown(
          height: height,
          // Full lockup (emblem + "JAIZA" + academy credit), matching the
          // Welcome screen's treatment instead of the emblem alone.
          child: const JaizaWordmark(),
        ),
        if (onBack != null)
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack,
            ),
          ),
      ],
    );
  }
}

/// Solid rounded card with a domed crest (mosque dome + crescent) used
/// behind the wordmark on Welcome, Get Started, and every auth screen via
/// [JaizaAuthHeader]. Single shared painter — change the shape here once
/// and it updates everywhere it's used.
class JaizaArchCrown extends StatelessWidget {
  const JaizaArchCrown({super.key, required this.child, this.height = 220});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _ArchCrownPainter(
              fill: isDark
                  ? scheme.surfaceContainerHigh
                  : Colors.white.withValues(alpha: 0.92),
              stroke: scheme.tertiary.withValues(alpha: 0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ArchCrownPainter extends CustomPainter {
  _ArchCrownPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final goldStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = stroke;
    final goldFill = Paint()
      ..style = PaintingStyle.fill
      ..color = stroke;

    // ---- Central pointed (mihrab) arch ----
    // Slightly narrowed (central ~72%) to leave room for a flanking
    // minaret on each side. Apex sits a little lower so the crescent has
    // room to crown it.
    final archLeft = w * 0.14;
    final archRight = w * 0.86;
    final springY = h * 0.62; // top of the arch pillars / where it curves
    final peakY = h * 0.18; // sharp apex of the pointed arch

    final arch = Path()
      ..moveTo(archLeft, h)
      ..lineTo(archLeft, springY)
      ..cubicTo(archLeft, h * 0.42, w * 0.34, h * 0.26, w * 0.50, peakY)
      ..cubicTo(w * 0.66, h * 0.26, archRight, h * 0.42, archRight, springY)
      ..lineTo(archRight, h)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fill, fill.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(arch, fillPaint);
    canvas.drawPath(arch, goldStroke);

    // Inner concentric arch line — the recessed look of a real mihrab niche.
    final innerStart = w * 0.20;
    final inner = Path()
      ..moveTo(innerStart, springY)
      ..cubicTo(innerStart, h * 0.45, w * 0.35, h * 0.31, w * 0.50, peakY + h * 0.07)
      ..cubicTo(
        w * 0.65,
        h * 0.31,
        w - innerStart,
        h * 0.45,
        w - innerStart,
        springY,
      );
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeJoin = StrokeJoin.round
        ..color = stroke.withValues(alpha: 0.45),
    );

    // ---- Two matching pencil-shaped minarets (rectangular shaft +
    // pointed tip), one on each side, identical size. ----
    final shaftHalf = w * 0.016;
    final tipY = h * 0.08;
    final capBottomY = h * 0.26;
    void pencilMinaret(double cx) {
      final p = Path()
        ..moveTo(cx - shaftHalf, h)
        ..lineTo(cx - shaftHalf, capBottomY)
        ..lineTo(cx, tipY) // pointed pencil tip
        ..lineTo(cx + shaftHalf, capBottomY)
        ..lineTo(cx + shaftHalf, h)
        ..close();
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.fill
          ..color = stroke.withValues(alpha: 0.14),
      );
      canvas.drawPath(p, goldStroke);
      // small balcony band just below the cap, a minaret hallmark
      final bandY = capBottomY + h * 0.05;
      canvas.drawLine(
        Offset(cx - shaftHalf * 2.2, bandY),
        Offset(cx + shaftHalf * 2.2, bandY),
        goldStroke,
      );
    }

    pencilMinaret(w * 0.07);
    pencilMinaret(w * 0.93);

    // ---- Crescent "C" crowning the arch apex ----
    final crescentR = h * 0.058;
    final crescentCenter = Offset(w * 0.5, peakY - crescentR * 0.7);
    final outerC = Path()
      ..addOval(Rect.fromCircle(center: crescentCenter, radius: crescentR));
    final innerC = Path()
      ..addOval(
        Rect.fromCircle(
          // offset up-and-right so the crescent opens toward the upper
          // right, like the reference "C".
          center: crescentCenter.translate(crescentR * 0.5, -crescentR * 0.18),
          radius: crescentR * 0.82,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, outerC, innerC),
      goldFill,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchCrownPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}

/// Domes-and-minarets silhouette anchored to the bottom of a screen, with
/// onion-dome bulges, drums, minaret balconies, finials and an arched
/// base wall for a more authentic mosque profile than plain geometric
/// triangles/half-circles.
class JaizaMosqueSkyline extends StatelessWidget {
  const JaizaMosqueSkyline({super.key, this.height = 92});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SkylinePainter(
          color: (isDark ? scheme.secondary : scheme.secondary)
              .withValues(alpha: isDark ? 0.3 : 0.24),
          accent: scheme.tertiary.withValues(alpha: isDark ? 0.22 : 0.18),
        ),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  _SkylinePainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  /// A proper onion-dome silhouette: short drum, bulbous swell, tapered
  /// neck, and a finial (spike + tiny crescent-orb) on top.
  void _onionDome(Path path, double cx, double baseY, double w, double h) {
    final drumW = w * 0.58;
    final domeW = w;
    final left = cx - drumW / 2;
    final right = cx + drumW / 2;
    final neckY = baseY - h * 0.16;
    final bulgeY = baseY - h * 0.62;
    final tipY = baseY - h * 0.88;

    path.moveTo(left, baseY);
    path.lineTo(left, neckY);
    path.cubicTo(
      cx - domeW / 2, bulgeY,
      cx - domeW * 0.12, tipY,
      cx, tipY,
    );
    path.cubicTo(
      cx + domeW * 0.12, tipY,
      cx + domeW / 2, bulgeY,
      right, neckY,
    );
    path.lineTo(right, baseY);
    path.close();
  }

  void _finial(Path path, double cx, double baseY, double h) {
    final stickW = h * 0.06;
    path.addRect(
      Rect.fromLTWH(cx - stickW / 2, baseY - h, stickW, h * 0.78),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(cx, baseY - h), radius: h * 0.16),
    );
  }

  /// Minaret with a tapered shaft, a balcony band partway up, and a small
  /// spired cap instead of a plain triangle roof.
  void _minaret(Path path, double cx, double baseY, double w, double towerH) {
    final shaftTopY = baseY - towerH;
    final balconyY = baseY - towerH * 0.62;
    final balconyW = w * 1.6;

    // shaft (slightly tapered)
    path.moveTo(cx - w * 0.55, baseY);
    path.lineTo(cx - w * 0.4, balconyY + 2);
    path.lineTo(cx + w * 0.4, balconyY + 2);
    path.lineTo(cx + w * 0.55, baseY);
    path.close();

    // balcony band
    path.addRect(
      Rect.fromLTWH(cx - balconyW / 2, balconyY - w * 0.18, balconyW, w * 0.3),
    );

    // upper shaft above balcony
    path.moveTo(cx - w * 0.32, balconyY);
    path.lineTo(cx - w * 0.16, shaftTopY);
    path.lineTo(cx + w * 0.16, shaftTopY);
    path.lineTo(cx + w * 0.32, balconyY);
    path.close();

    // conical cap
    path.moveTo(cx - w * 0.22, shaftTopY);
    path.lineTo(cx, shaftTopY - towerH * 0.16);
    path.lineTo(cx + w * 0.22, shaftTopY);
    path.close();

    _finial(path, cx, shaftTopY - towerH * 0.16, towerH * 0.14);
  }

  /// Repeating small arched windows along the base wall.
  void _archedWalls(Canvas canvas, Paint paint, Size size, double wallH) {
    final baseY = size.height;
    final wallTop = baseY - wallH;
    canvas.drawRect(
      Rect.fromLTRB(0, wallTop, size.width, baseY),
      paint,
    );
    final archW = size.width / 18;
    final archPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;
    for (var i = 0; i < 18; i++) {
      final cx = archW * (i + 0.5);
      final archPath = Path()
        ..moveTo(cx - archW * 0.28, baseY)
        ..lineTo(cx - archW * 0.28, wallTop + wallH * 0.55)
        ..arcToPoint(
          Offset(cx + archW * 0.28, wallTop + wallH * 0.55),
          radius: Radius.circular(archW * 0.28),
          clockwise: true,
        )
        ..lineTo(cx + archW * 0.28, baseY)
        ..close();
      canvas.drawPath(archPath, archPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final baseY = size.height;
    final domesPath = Path();

    _minaret(domesPath, size.width * 0.05, baseY, size.width * 0.032, size.height * 0.78);
    _onionDome(domesPath, size.width * 0.19, baseY, size.width * 0.15, size.height * 0.5);
    _minaret(domesPath, size.width * 0.335, baseY, size.width * 0.028, size.height * 0.92);
    _onionDome(domesPath, size.width * 0.5, baseY, size.width * 0.24, size.height * 1.0);
    _minaret(domesPath, size.width * 0.665, baseY, size.width * 0.028, size.height * 0.92);
    _onionDome(domesPath, size.width * 0.81, baseY, size.width * 0.15, size.height * 0.5);
    _minaret(domesPath, size.width * 0.95, baseY, size.width * 0.032, size.height * 0.78);

    canvas.saveLayer(Offset.zero & size, Paint());
    _archedWalls(canvas, paint, size, size.height * 0.22);
    canvas.restore();
    canvas.drawPath(domesPath, paint);

    // Faint accent line tracing the roofline for a touch of depth.
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent;
    canvas.drawPath(domesPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.accent != accent;
}

/// "—— ✦ ——" style ornamental section divider, optionally wrapping a label.
class JaizaFlourishDivider extends StatelessWidget {
  const JaizaFlourishDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final line = Expanded(
      child: Container(height: 1, color: scheme.tertiary.withValues(alpha: 0.4)),
    );
    final star = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(Icons.auto_awesome, size: 14, color: scheme.tertiary),
    );
    if (label == null) {
      return Row(children: [line, star, line]);
    }
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        line,
      ],
    );
  }
}

/// The real Jaiza logo (gold calligraphy mark, transparent background).
/// `compact` shows just the emblem (used inside the small arch header on
/// auth screens); the full version is the emblem + "JAIZA" + academy
/// credit line, both baked into the source artwork. Wrapped in a
/// [FittedBox] so it scales to whatever space its parent gives it —
/// the same image asset works at any screen size without distortion or
/// overflow, and the transparent background blends with light/dark theme
/// surfaces automatically.
class JaizaWordmark extends StatelessWidget {
  const JaizaWordmark({super.key, this.compact = false, this.maxSize});

  final bool compact;

  /// Overrides the default cap below. Still intersected with whatever the
  /// parent's own constraints allow, so this only ever raises/lowers the
  /// ceiling — it can't force an overflow.
  final double? maxSize;

  @override
  Widget build(BuildContext context) {
    final asset = compact
        ? 'assets/branding/jaiza_emblem.png'
        : 'assets/branding/jaiza_logo_full.png';
    // A sensible default size for "plenty of room" contexts (e.g. inside a
    // loose Center), with FittedBox still shrinking it further when the
    // parent gives less space than that — covers both ends of "adjustable
    // on all screen sizes" without the logo ballooning to fill whatever
    // space happens to be available.
    final size = maxSize ?? (compact ? 64 : 170);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size, maxWidth: size),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset(asset),
      ),
    );
  }
}

/// Decorative laurel-leaf flanked quote block.
class JaizaQuoteBlock extends StatelessWidget {
  const JaizaQuoteBlock({super.key, required this.quote, required this.source});

  final String quote;
  final String source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final leaf = Icon(Icons.eco_outlined, size: 18, color: scheme.tertiary);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: leaf,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '“$quote”',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            leaf,
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '($source)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
