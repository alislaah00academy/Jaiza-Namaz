import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/badge_definitions.dart';
import '../../../providers/providers.dart';

class _HubTile {
  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}

/// Main hub: categories + streak summary + badges strip.
class HomeHubScreen extends ConsumerWidget {
  const HomeHubScreen({super.key});

  static const _tiles = [
    _HubTile(
      title: 'Faraiz',
      subtitle: 'Obligatory prayers',
      icon: Icons.wb_twilight_rounded,
      path: '/app/fard',
    ),
    _HubTile(
      title: 'Nawafil',
      subtitle: 'Optional prayers',
      icon: Icons.auto_awesome_outlined,
      path: '/app/nawafil',
    ),
    _HubTile(
      title: 'Qaza',
      subtitle: 'Missed prayers',
      icon: Icons.history_edu_outlined,
      path: '/app/qaza',
    ),
    _HubTile(
      title: 'Benefits',
      subtitle: 'Why prayer matters',
      icon: Icons.favorite_outline,
      path: '/app/benefits',
    ),
    _HubTile(
      title: 'About Us',
      subtitle: AppStrings.academyCredit,
      icon: Icons.info_outline,
      path: '/app/about',
    ),
    _HubTile(
      title: 'Contact',
      subtitle: 'Reach Al Islaah Academy',
      icon: Icons.mail_outline,
      path: '/app/contact',
    ),
    _HubTile(
      title: 'Donation',
      subtitle: 'Support the project',
      icon: Icons.volunteer_activism_outlined,
      path: '/app/donation',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakStreamProvider);
    final userAsync = ref.watch(appUserStreamProvider);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu alaikum',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                userAsync.when(
                  data: (u) => Text(
                    u?.name.isNotEmpty == true ? u!.name : 'Muslim',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const Text('Muslim'),
                ),
                const SizedBox(height: 16),
                streakAsync.when(
                  data: (s) {
                    final cur = s?.currentStreak ?? 0;
                    final best = s?.longestStreak ?? 0;
                    return Row(
                      children: [
                        _StreakChip(
                          icon: Icons.local_fire_department_outlined,
                          label: '$cur day streak',
                        ),
                        const SizedBox(width: 12),
                        _StreakChip(
                          icon: Icons.emoji_events_outlined,
                          label: 'Best: $best',
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Badges',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                streakAsync.when(
                  data: (s) {
                    final unlocked = s?.badgesUnlocked ?? [];
                    return SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kBadgeDefinitions.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final b = kBadgeDefinitions[i];
                          final on = unlocked.contains(b.id);
                          return _BadgeCard(definition: b, unlocked: on);
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text(AppStrings.askQuestions),
                      onPressed: () => context.push(
                        '/app/coming-soon?title=${Uri.encodeComponent(AppStrings.askQuestions)}',
                      ),
                    ),
                    ActionChip(
                      label: const Text(AppStrings.prayerPhilosophy),
                      onPressed: () => context.push(
                        '/app/coming-soon?title=${Uri.encodeComponent(AppStrings.prayerPhilosophy)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = _tiles[index];
                return _CategoryCard(tile: t);
              },
              childCount: _tiles.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.definition, required this.unlocked});

  final BadgeDefinition definition;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                unlocked ? Icons.verified : Icons.lock_outline,
                color: unlocked
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const Spacer(),
              Text(
                definition.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.tile});

  final _HubTile tile;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(tile.path),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tile.icon, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(
                tile.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                tile.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
