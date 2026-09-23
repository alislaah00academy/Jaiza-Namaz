import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/qaza_tracker.dart';
import 'qaza_widgets.dart';

/// Qaza for one prayer: progress, "I prayed some", the dated list Jaiza
/// tracked, and what is left of the user's estimate.
class QazaPrayerScreen extends ConsumerStatefulWidget {
  const QazaPrayerScreen({super.key, required this.prayer});

  final PrayerName prayer;

  @override
  ConsumerState<QazaPrayerScreen> createState() => _QazaPrayerScreenState();
}

class _QazaPrayerScreenState extends ConsumerState<QazaPrayerScreen> {
  static const _visibleDays = 30;
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final p = widget.prayer;
    final summary = ref.watch(qazaOverviewProvider).byPrayer[p];
    if (summary == null) {
      return const Center(
        child: Text('Qaza is tracked for the five Fard only.'),
      );
    }
    final label = prayerLabel(p);
    // The repository stores one Qaza per prayer per day.
    final doneToday = ref.watch(qazaTodayCountForProvider(p)) > 0;
    final maxToday = doneToday ? 0 : 1;
    final dayFmt = DateFormat('EEEE, d MMMM');
    final tracked = summary.trackedMissed;
    final indices = [for (var i = tracked.length - 1; i >= 0; i--) i];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  JzAvatar(icon: prayerIcon(p), size: 44, iconSize: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${jzCount(summary.remaining)} remaining',
                          style: t.headlineSmall,
                        ),
                        Text(
                          '${jzCount(summary.completed)} of '
                          '${jzCount(summary.total)} done',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              JzBar(
                value: summary.total == 0
                    ? 0
                    : summary.completed / summary.total,
                height: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('I prayed some Qaza $label', style: t.titleMedium),
              const SizedBox(height: 12),
              if (maxToday == 0)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Today's Qaza $label is recorded. Come back tomorrow "
                        'for the next one.',
                        style: t.bodyMedium,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: JzStepper(
                        value: _count.clamp(1, maxToday),
                        max: maxToday,
                        height: 48,
                        large: false,
                        onChanged: (v) => setState(() => _count = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: summary.remaining == 0
                          ? null
                          : () => markQazaDone(context, ref, p),
                      child: const Text('Mark done'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JzSectionLabel('Tracked by Jaiza · ${jzCount(tracked.length)}'),
        if (tracked.isEmpty)
          JzCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No missed $label since you started using Jaiza.',
              style: t.bodyMedium,
            ),
          )
        else
          JzCard(
            child: Column(
              children: [
                for (var k = 0; k < indices.length && k < _visibleDays; k++)
                  Builder(
                    builder: (context) {
                      final i = indices[k];
                      final madeUp = summary.madeUpOn(i);
                      return JzPrayerRow(
                        name: dayFmt.format(tracked[i]),
                        checked: madeUp != null,
                        sub: madeUp == null
                            ? 'Missed'
                            : 'Made up on ${DateFormat('d MMMM').format(madeUp)}',
                        showDivider:
                            k < indices.length - 1 && k < _visibleDays - 1,
                      );
                    },
                  ),
                if (indices.length > _visibleDays)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      '+ ${jzCount(indices.length - _visibleDays)} earlier days',
                      style: t.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        if (summary.estimate > 0) ...[
          const SizedBox(height: 14),
          JzCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: c.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From your estimate', style: t.titleSmall),
                      Text(
                        '${jzCount(summary.estimateRemaining)} remaining · '
                        'these carry no date',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
