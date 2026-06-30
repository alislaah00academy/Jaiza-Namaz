import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/jaiza_hero_emblem.dart';
import '../../../core/widgets/jaiza_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: JaizaHeroEmblem(size: 88, iconSize: 44)),
        const SizedBox(height: 20),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.academyCredit,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Jaiza helps Muslims track obligatory prayers, optional '
            'nawafil, and qaza with gentle motivation — streaks, badges, and '
            'clear progress.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 14),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Our goal is to support consistency with adab: simple design, honest '
            'tracking, and room to grow in worship.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 18),
        JaizaSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              Icons.menu_book_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              'الاصلاح اکیڈمی کا مختصر تعارف',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            subtitle: const Text(
              'Brief introduction to Al Islaah Academy (Urdu)',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onTap: () => context.push('/app/academy-intro'),
          ),
        ),
      ],
    );
  }
}
