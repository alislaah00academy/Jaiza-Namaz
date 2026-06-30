import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/jaiza_dates.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../providers/providers.dart';
import '../../../services/prayer_times_service.dart';

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

/// Individual home: today's date + current prayer card, and the main
/// feature grid. Streak/badge UI was removed from here per product
/// decision — the underlying streak computation keeps running unchanged.
class HomeHubScreen extends ConsumerWidget {
  const HomeHubScreen({super.key});

  static const _tiles = [
    _HubTile(
      title: 'Obligatory Prayers',
      subtitle: 'Faraiz',
      icon: Icons.mosque_outlined,
      path: '/app/fard',
    ),
    _HubTile(
      title: 'Nawafil Prayers',
      subtitle: 'Optional prayers',
      icon: Icons.front_hand_outlined,
      path: '/app/nawafil',
    ),
    _HubTile(
      title: 'Qaza Prayers',
      subtitle: 'Missed prayers',
      icon: Icons.history_edu_outlined,
      path: '/app/qaza',
    ),
    _HubTile(
      title: 'Fazail of prayers',
      subtitle: 'Virtues & rewards',
      icon: Icons.menu_book_outlined,
      path: '/app/benefits',
    ),
    _HubTile(
      title: 'About Us',
      subtitle: 'Al Islaah Academy',
      icon: Icons.info_outline,
      path: '/app/about',
    ),
    _HubTile(
      title: 'Contact Us',
      subtitle: 'Reach out to us',
      icon: Icons.call_outlined,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridColumns = AppBreakpoints.hubGridCrossAxisCount(
          constraints.maxWidth,
        );
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                // Below ~360 logical px there isn't room for the card and
                // the wordmark side by side without squeezing the card's
                // Start/End row — stack them instead of overflowing.
                child: constraints.maxWidth < 360
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _PrayerStatusCard(),
                          const SizedBox(height: 12),
                          const Center(
                            child: JaizaWordmark(compact: true, maxSize: 110),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(flex: 3, child: _PrayerStatusCard()),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                child: JaizaWordmark(
                                  compact: true,
                                  maxSize: 130,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final t = _tiles[index];
                  return _CategoryCard(tile: t).jaizaEnter(index: index);
                }, childCount: _tiles.length),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: JaizaMosqueSkyline(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Today's date (Hijri + Gregorian) and the currently-active Fard prayer's
/// start/end window, refreshed every minute so the active prayer updates
/// itself as the day goes on.
class _PrayerStatusCard extends ConsumerStatefulWidget {
  const _PrayerStatusCard();

  @override
  ConsumerState<_PrayerStatusCard> createState() => _PrayerStatusCardState();
}

class _PrayerStatusCardState extends ConsumerState<_PrayerStatusCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(currentPrayerCardProvider);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final cardAsync = ref.watch(currentPrayerCardProvider);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        boxShadow: AppTokens.softShadow(context),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatHijriDate(now),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatGregorianFull(now),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: 10),
          cardAsync.when(
            data: (data) => _ActivePrayerRow(data: data),
            loading: () => const SizedBox(
              height: 44,
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, st) => Text(
              'Prayer times unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivePrayerRow extends StatelessWidget {
  const _ActivePrayerRow({required this.data});

  final ({DailyPrayerSchedule today, PrayerWindowStatus status}) data;

  String _fmt(DateTime t) => DateFormat('hh:mm a').format(t.toLocal());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeKey = data.status.activePrayerKey;
    final isActive = activeKey != null;
    final window = isActive
        ? data.today.fardWindows.firstWhere((w) => w.key == activeKey)
        : null;
    final label = window?.label ?? data.status.nextLabel;
    final start = window?.start ?? data.status.nextTime;
    final end = window?.end ?? data.status.targetTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            isActive
                ? const PulsingDot(color: Colors.green, size: 9)
                : Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.outline,
                    ),
                  ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            isActive ? 'Current Prayer' : 'Next Prayer',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? Colors.green[700] : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: scheme.outlineVariant, height: 1),
        const SizedBox(height: 10),
        // Two flexible halves (not a fixed-width Row) so this never
        // overflows, no matter how narrow the card gets next to the logo.
        Row(
          children: [
            Expanded(
              child: _TimeBlock(
                icon: Icons.wb_twilight_outlined,
                label: 'Start',
                time: _fmt(start),
              ),
            ),
            Container(width: 1, height: 28, color: scheme.outlineVariant),
            Expanded(
              child: _TimeBlock(
                icon: Icons.brightness_high_outlined,
                label: 'End',
                time: _fmt(end),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.icon,
    required this.label,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  time,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.tile});

  final _HubTile tile;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Material(
      color: c.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: () => context.push(tile.path),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(color: c.outline.withValues(alpha: 0.18)),
            // A tighter, lighter shadow than AppTokens.softShadow (tuned
            // for big standalone cards) — that one's 18px blur bled into
            // neighboring grid tiles at the corners where 4 cards meet.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.primaryContainer.withValues(alpha: 0.65),
                    border: Border.all(
                      color: c.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(tile.icon, color: c.primary, size: 28),
                ),
                const Spacer(),
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  tile.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
