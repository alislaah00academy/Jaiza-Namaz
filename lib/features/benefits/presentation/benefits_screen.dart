import 'package:flutter/material.dart';

import '../../../core/widgets/jaiza_scaffold.dart';

/// Static content: spiritual benefits of Salah (expand later / translations).
class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Fazail of Prayers',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _BenefitTile(
          icon: Icons.self_improvement,
          title: 'Closeness to Allah',
          body:
              'Salah is a direct link between the servant and the Lord. It reminds us that we turn to Him in every state.',
        ),
        _BenefitTile(
          icon: Icons.balance,
          title: 'Discipline & structure',
          body:
              'Praying on time builds patience, order, and mindfulness throughout the day.',
        ),
        _BenefitTile(
          icon: Icons.favorite_outline,
          title: 'Purification',
          body:
              'Regular prayer washes away slips, renews intention, and keeps the heart soft.',
        ),
        _BenefitTile(
          icon: Icons.groups_2_outlined,
          title: 'Community',
          body:
              'Congregational prayer strengthens brotherhood and sisterhood in faith.',
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: JaizaSurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primaryContainer.withValues(alpha: 0.7),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: c.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
