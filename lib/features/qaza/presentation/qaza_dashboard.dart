import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/qaza_plan.dart';
import 'qaza_form_step.dart';

/// Returning-user view: per-prayer Qaza progress + a quick "mark one done"
/// action, replacing the old single combined backlog/progress card.
class QazaDashboard extends ConsumerWidget {
  const QazaDashboard({super.key, required this.plan, required this.onEdit});

  final QazaPlanParsed plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var totalRemaining = 0;
    for (final def in kFardPrayerDefs) {
      final backlog = plan.backlogFor(def.name);
      final completed = ref.watch(qazaCompletedForProvider(def.name));
      totalRemaining += (backlog.totalDays - completed).clamp(0, 1 << 30);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qaza Prayers',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalRemaining estimated remaining (all prayers)',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit backlog'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final def in kFardPrayerDefs)
          _PrayerProgressCard(name: def.name, label: def.label, plan: plan),
      ],
    );
  }
}

class _PrayerProgressCard extends ConsumerWidget {
  const _PrayerProgressCard({
    required this.name,
    required this.label,
    required this.plan,
  });

  final PrayerName name;
  final String label;
  final QazaPlanParsed plan;

  Future<void> _markOneDone(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref
          .read(prayerRepositoryProvider)
          .upsertPrayer(
            userId: uid,
            prayerName: name,
            type: PrayerType.qaza,
            status: PrayerStatus.completed,
          );
      if (context.mounted) {
        AppSnackBar.success(
          context,
          'Qaza $label recorded. May Allah accept it.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not save.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backlog = plan.backlogFor(name);
    final completed = ref.watch(qazaCompletedForProvider(name));
    final remaining = (backlog.totalDays - completed).clamp(0, 1 << 30);
    final progress = backlog.totalDays == 0
        ? 1.0
        : (completed / backlog.totalDays).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: JaizaSurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(
                    qazaIconFor(name),
                    color: scheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Qaza $label Namaz',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (backlog.frequency != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                    ),
                    child: Text(
                      backlog.frequency!.label,
                      style: textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Remaining: $remaining',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  'Completed: $completed / ${backlog.totalDays}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              style: AppTheme.tonalButtonStyle(context),
              onPressed: remaining == 0
                  ? null
                  : () => _markOneDone(context, ref),
              child: Text('Mark one Qaza $label completed'),
            ),
          ],
        ),
      ),
    );
  }
}
