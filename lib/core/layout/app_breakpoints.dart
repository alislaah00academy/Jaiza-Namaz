import 'package:flutter/material.dart';

/// Width thresholds for adaptive layout (Material-inspired handoff points).
abstract final class AppBreakpoints {
  static const double navigationRailMinWidth = 600;
  static const double hubGridMedium = 600;
  static const double hubGridLarge = 900;
  static const double maxContentWidth = 900;

  static bool useNavigationRailForWidth(double width) =>
      width >= navigationRailMinWidth;

  static int hubGridCrossAxisCount(double width) {
    if (width >= hubGridLarge) return 4;
    if (width >= hubGridMedium) return 3;
    return 2;
  }
}

/// Constrains wide layouts so text blocks do not span full ultrawide monitors.
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}

/// Centers narrow forms (auth, etc.) on tablet/desktop.
class AuthMaxWidth extends StatelessWidget {
  const AuthMaxWidth({super.key, required this.child});

  static const double maxWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}
