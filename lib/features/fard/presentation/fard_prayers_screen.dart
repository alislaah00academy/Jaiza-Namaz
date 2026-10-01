import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaiza_core/jaiza_core.dart' show SubjectRef;

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import 'fard_history_section.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/errors/firebase_auth_messages.dart';

/// Lists six Fard prayers with informational windows and mark completed/missed.
class FardPrayersScreen extends ConsumerWidget {
  const FardPrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final today = ref.watch(todayFardMapProvider);

    if (uid == null) {
      return Center(child: Text(context.l10n.signInRequired));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const FardHistorySection(),
        const SizedBox(height: 16),
        today.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Center(
            child: Text(
              context.l10n.couldNotLoad(mapGenericError(e, context.l10n)),
            ),
          ),
          data: (map) {
            final completedCount = kFardPrayerDefs
                .where((d) => map[d.name]?.status == PrayerStatus.completed)
                .length;
            final progress = completedCount / kFardPrayerDefs.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                JaizaSurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.todaysFardProgress,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.completedOfTotal(
                          completedCount,
                          kFardPrayerDefs.length,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (map.isEmpty && completedCount == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      context.l10n.noPrayersYet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ...kFardPrayerDefs.map((def) {
                  final log = map[def.name];
                  final status = log?.status;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: JaizaSurfaceCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  def.label(context.l10n),
                                  style: Theme.of(context).textTheme.titleMedium
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
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.windowHint(
                              def.startHint(context.l10n),
                              def.endHint(context.l10n),
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _mark(
                                    context,
                                    ref,
                                    uid,
                                    def.name,
                                    PrayerStatus.completed,
                                  ),
                                  child: Text(context.l10n.markAsPrayed),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonal(
                                  style: AppTheme.tonalButtonStyle(context),
                                  onPressed: () => _mark(
                                    context,
                                    ref,
                                    uid,
                                    def.name,
                                    PrayerStatus.missed,
                                  ),
                                  child: Text(context.l10n.statusMissed),
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
        ),
      ],
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
      await ref
          .read(prayerRepositoryProvider)
          .upsertPrayer(
            subject: SubjectRef.self(uid),
            markedBy: uid,
            prayerName: name,
            type: PrayerType.fard,
            status: status,
          );
      if (context.mounted && status == PrayerStatus.completed) {
        AppSnackBar.success(context, context.l10n.namazMarkedSuccess);
      } else if (context.mounted) {
        AppSnackBar.success(context, context.l10n.recordedAsMissed);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorSaveFailed);
      }
    }
  }
}
