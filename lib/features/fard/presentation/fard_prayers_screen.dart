import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Lists six Fard prayers with informational windows and mark completed/missed.
class FardPrayersScreen extends ConsumerWidget {
  const FardPrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final today = ref.watch(todayFardMapProvider);

    if (uid == null) {
      return const Center(child: Text('Sign in required'));
    }

    return today.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (map) {
        final completedCount = kFardPrayerDefs
            .where(
              (d) => map[d.name]?.status == PrayerStatus.completed,
            )
            .length;
        final progress = completedCount / kFardPrayerDefs.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Today's Fard progress",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$completedCount / ${kFardPrayerDefs.length} completed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            if (map.isEmpty && completedCount == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  AppStrings.noPrayersYet,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ...kFardPrayerDefs.map((def) {
              final log = map[def.name];
              final status = log?.status;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              def.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (status == PrayerStatus.completed)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          else if (status == PrayerStatus.missed)
                            Icon(
                              Icons.cancel_outlined,
                              color: Theme.of(context).colorScheme.error,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Window: ${def.startHint} — ${def.endHint}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: () => _mark(
                                context,
                                ref,
                                uid,
                                def.name,
                                PrayerStatus.completed,
                              ),
                              child: const Text('Mark as prayed'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _mark(
                                context,
                                ref,
                                uid,
                                def.name,
                                PrayerStatus.missed,
                              ),
                              child: const Text('Missed'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _mark(
    BuildContext context,
    WidgetRef ref,
    String uid,
    PrayerName name,
    PrayerStatus status,
  ) async {
    try {
      await ref.read(prayerRepositoryProvider).upsertPrayer(
            userId: uid,
            prayerName: name,
            type: PrayerType.fard,
            status: status,
          );
      if (context.mounted && status == PrayerStatus.completed) {
        AppSnackBar.success(context, AppStrings.namazMarkedSuccess);
      } else if (context.mounted) {
        AppSnackBar.success(context, 'Recorded as missed. Stay steadfast.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not save. Try again.');
      }
    }
  }
}
