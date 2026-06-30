import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralised motion vocabulary so animations stay consistent across the
/// app. "Noticeable & lively" tuning per product direction — slightly
/// larger offsets and springy curves, but kept short so they never get in
/// the user's way.
abstract final class JaizaMotion {
  static const fast = Duration(milliseconds: 280);
  static const medium = Duration(milliseconds: 450);
  static const slow = Duration(milliseconds: 650);

  /// Per-item delay step for staggered lists/grids.
  static const stagger = Duration(milliseconds: 70);

  static const enterCurve = Curves.easeOutBack;
}

extension JaizaAnimateX on Widget {
  /// Lively entrance: fade + rise + slight scale, with an optional stagger
  /// delay (multiply [index] by [JaizaMotion.stagger]).
  Widget jaizaEnter({int index = 0, Duration? delay, double beginY = 0.18}) {
    final d = delay ?? (JaizaMotion.stagger * index);
    return animate(delay: d)
        .fadeIn(duration: JaizaMotion.medium, curve: Curves.easeOut)
        .moveY(
          begin: beginY * 120,
          end: 0,
          duration: JaizaMotion.medium,
          curve: Curves.easeOutCubic,
        )
        .scaleXY(
          begin: 0.94,
          end: 1,
          duration: JaizaMotion.medium,
          curve: JaizaMotion.enterCurve,
        );
  }

  /// Soft looping pulse — for "live" indicators like the current-prayer dot.
  Widget jaizaPulse() {
    return animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
      begin: 1,
      end: 1.35,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );
  }

  /// One-shot celebratory pop (scale overshoot) — e.g. when a value lands.
  Widget jaizaPop({Duration? delay}) {
    return animate(delay: delay)
        .scaleXY(
          begin: 0.6,
          end: 1,
          duration: JaizaMotion.fast,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: JaizaMotion.fast);
  }
}

/// A small dot that gently pulses with a halo — used for the "current
/// prayer" live indicator. Pure native animation, theme-coloured.
class PulsingDot extends StatelessWidget {
  const PulsingDot({super.key, this.color = Colors.green, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.6,
      height: size * 1.6,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ).jaizaPulse(),
      ),
    );
  }
}

/// Native (no asset) animated checkmark that draws itself in — used for
/// the prayer-complete confirmation so it perfectly matches the gold theme.
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({super.key, required this.color, this.size = 72});

  final Color color;
  final double size;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _CheckPainter(color: widget.color, progress: _c.value),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.46;

    // Ring draws in first (0 → 0.6), then the tick (0.45 → 1.0).
    final ringT = (progress / 0.6).clamp(0.0, 1.0);
    final tickT = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * ringT,
      false,
      ringPaint,
    );

    final p1 = Offset(w * 0.30, h * 0.52);
    final p2 = Offset(w * 0.44, h * 0.66);
    final p3 = Offset(w * 0.72, h * 0.36);
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final tick = Path()..moveTo(p1.dx, p1.dy);
    if (tickT <= 0.5) {
      final t = tickT / 0.5;
      tick.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      tick.lineTo(p2.dx, p2.dy);
      final t = (tickT - 0.5) / 0.5;
      tick.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }
    if (tickT > 0) canvas.drawPath(tick, tickPaint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
