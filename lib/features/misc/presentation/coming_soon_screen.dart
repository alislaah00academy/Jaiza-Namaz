import 'package:flutter/material.dart';

import '../../../core/widgets/jaiza_hero_emblem.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../core/l10n/l10n.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, this.featureTitle});

  final String? featureTitle;

  @override
  Widget build(BuildContext context) {
    return JaizaBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: JaizaSurfaceCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  JaizaHeroEmblem(
                    size: 88,
                    iconSize: 42,
                    icon: Icons.hourglass_top_rounded,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    featureTitle ?? context.l10n.comingSoonTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.comingSoonBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
