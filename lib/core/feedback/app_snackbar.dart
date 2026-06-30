import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Consistent SnackBars for success / error feedback.
abstract final class AppSnackBar {
  static void success(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimary,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onErrorContainer,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
