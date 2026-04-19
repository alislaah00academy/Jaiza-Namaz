import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(
          Icons.mosque_rounded,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.academyCredit,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Jaiza (Namaz) helps Muslims track obligatory prayers, optional '
          'nawafil, and qaza with gentle motivation — streaks, badges, and '
          'clear progress.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Our goal is to support consistency with adab: simple design, honest '
          'tracking, and room to grow in worship.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
