import 'package:flutter/material.dart';

/// Static content: spiritual benefits of Salah (expand later / translations).
class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Benefits of Prayer',
          style: Theme.of(context).textTheme.headlineSmall,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
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
