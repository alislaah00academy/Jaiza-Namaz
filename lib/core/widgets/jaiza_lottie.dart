import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Asset paths for the bundled Lottie animations (see
/// assets/animations/SOURCES.md for provenance + licensing notes).
abstract final class JaizaAnims {
  static const loading = 'assets/animations/loading.json';
  static const celebration = 'assets/animations/celebration.json';
  static const email = 'assets/animations/email.json';
}

/// Thin wrapper over [Lottie.asset] that never breaks the UI: if the JSON
/// asset is missing or fails to parse, it renders [fallback] (or nothing)
/// instead of throwing, so swapping/removing animation files can't crash a
/// screen.
class JaizaLottie extends StatelessWidget {
  const JaizaLottie({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.fallback,
    this.controller,
    this.onLoaded,
  });

  final String asset;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;
  final Widget? fallback;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      repeat: repeat,
      fit: fit,
      controller: controller,
      onLoaded: onLoaded,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? SizedBox(width: width, height: height),
    );
  }
}
