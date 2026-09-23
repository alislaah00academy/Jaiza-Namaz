import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/qaza_tracker.dart';

String prayerLabel(PrayerName p) =>
    '${p.name[0].toUpperCase()}${p.name.substring(1)}';

IconData prayerIcon(PrayerName p) => switch (p) {
  PrayerName.fajr => Icons.wb_twilight_outlined,
  PrayerName.zuhr => Icons.wb_sunny_outlined,
  PrayerName.asr => Icons.light_mode_outlined,
  PrayerName.maghrib => Icons.brightness_6_outlined,
  PrayerName.isha => Icons.nights_stay_outlined,
  _ => Icons.access_time_rounded,
};

/// Records one made-up Qaza of [prayer] for today. The repository keeps
/// one Qaza log per prayer per day, so a second tap the same day is a no-op.
Future<void> markQazaDone(
  BuildContext context,
  WidgetRef ref,
  PrayerName prayer, {
  String? personId,
}) async {
  final me = ref.read(currentUserProvider)?.uid;
  if (me == null) return;
  final uid = personId ?? me;
  try {
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          userId: uid,
          prayerName: prayer,
          type: PrayerType.qaza,
          status: PrayerStatus.completed,
          ownerUid: uid == me ? null : me,
        );
    if (context.mounted) {
      AppSnackBar.success(
        context,
        'Qaza ${prayerLabel(prayer)} recorded. May Allah accept it.',
      );
    }
  } catch (_) {
    if (context.mounted) AppSnackBar.error(context, 'Could not save.');
  }
}

/// "How Qaza works in Jaiza" bottom sheet.
Future<void> showQazaHowItWorks(BuildContext context) {
  final items = <(IconData, String, String)>[
    (
      Icons.merge_type_rounded,
      'Two kinds, one list',
      'Prayers you miss while using Jaiza are added for you, with their date. '
          'Prayers from before Jaiza are whatever estimate you enter.',
    ),
    (
      Icons.event_available_outlined,
      'Count from Bulugh',
      'Your backlog starts the day you became Islamically accountable — not '
          'from birth.',
    ),
    (
      Icons.balance_outlined,
      'An estimate is enough',
      'If you do not remember exactly, enter your most reasonable guess. Islam '
          'asks for sincere effort where the exact number is unknown.',
    ),
    (
      Icons.looks_5_outlined,
      'Only the five Fard',
      'Fajr, Zuhr, Asr, Maghrib and Isha. Nawafil are never counted as Qaza.',
    ),
  ];
  return showJzSheet(
    context,
    builder: (ctx) {
      final t = Theme.of(ctx).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How Qaza works in Jaiza', style: t.headlineSmall),
          const SizedBox(height: 20),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JzAvatar(icon: i.$1, size: 40, iconSize: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.$2, style: t.titleSmall),
                        const SizedBox(height: 2),
                        Text(i.$3, style: t.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      );
    },
  );
}

/// Total card: Total Qaza, Tracked by Jaiza, and either the user's estimate
/// or an "Add an estimate" row.
class QazaTotalCard extends StatelessWidget {
  const QazaTotalCard({
    super.key,
    required this.overview,
    this.allowEstimate = true,
  });

  final QazaOverview overview;

  /// Children have no estimate backend, so their card omits that row.
  final bool allowEstimate;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final sinceLabel = '${overview.since.day} ${_month(overview.since.month)}';
    Widget line(String title, String sub, String value, {Widget? trailing}) =>
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyLarge),
                  Text(sub, style: t.bodySmall),
                ],
              ),
            ),
            Text(value, style: t.titleSmall),
            SizedBox(width: 28, child: trailing),
          ],
        );
    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Total Qaza', style: t.titleMedium)),
              Text(jzCount(overview.remaining), style: t.headlineSmall),
            ],
          ),
          const JzDivider(),
          line(
            'Tracked by Jaiza',
            'Missed since $sinceLabel',
            jzCount(overview.trackedTotal),
          ),
          if (allowEstimate) const JzDivider(),
          if (!allowEstimate)
            const SizedBox.shrink()
          else if (overview.hasEstimate)
            InkWell(
              onTap: () => context.push('/app/qaza/estimate'),
              child: line(
                'Your estimate',
                'Before you installed Jaiza',
                jzCount(overview.estimateTotal),
                trailing: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            InkWell(
              onTap: () => context.push('/app/qaza/estimate'),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: c.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add an estimate', style: t.bodyLarge),
                        Text(
                          'Have Qaza from before Jaiza? Add it once.',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const JzChevron(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _month(int m) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][m - 1];

/// Per-prayer card with progress and the "Mark Qaza done" action.
class QazaPrayerCard extends ConsumerWidget {
  const QazaPrayerCard({super.key, required this.summary, this.personId});

  final QazaPrayerSummary summary;

  /// A child's id when shown on a child's Qaza; null for the user.
  final String? personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final p = summary.prayer;
    final doneToday = personId == null
        ? ref.watch(qazaTodayCountForProvider(p)) > 0
        : summary.completedDates.any((d) => _isToday(d));
    void open() => personId == null
        ? context.push('/app/qaza/prayer/${p.name}')
        : markQazaDone(context, ref, p, personId: personId);
    return JzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: personId == null ? open : null,
      child: Column(
        children: [
          Row(
            children: [
              JzAvatar(icon: prayerIcon(p), size: 40, iconSize: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(prayerLabel(p), style: t.titleSmall),
                        ),
                        Text(
                          '${jzCount(summary.remaining)} left',
                          style: t.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    JzBar(
                      value: summary.total == 0
                          ? 0
                          : summary.completed / summary.total,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${jzCount(summary.completed)} of ${jzCount(summary.total)} done',
                      style: t.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: c.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: summary.remaining == 0 || doneToday
                      ? null
                      : () => markQazaDone(context, ref, p, personId: personId),
                  icon: Icon(
                    doneToday
                        ? Icons.check_circle_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(doneToday ? 'Done for today' : 'Mark Qaza done'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(52, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: open,
                child: const Icon(Icons.add_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _isToday(DateTime d) {
  final n = DateTime.now();
  return d.year == n.year && d.month == n.month && d.day == n.day;
}
