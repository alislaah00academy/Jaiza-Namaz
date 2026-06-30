import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/jaiza_strip_prayers.dart';
import '../../core/constants/prayer_catalog.dart';
import '../../core/feedback/app_snackbar.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/models/prayer_log.dart';
import '../../providers/providers.dart';
import 'home_widget_bridge.dart';
import 'jaiza_scaffold.dart';

/// Compact five-prayer strip matching the native home widget layout.
class JaizaPrayerStrip extends ConsumerWidget {
  const JaizaPrayerStrip({super.key});

  String _label(PrayerName name) {
    return kFardPrayerDefs.firstWhere((d) => d.name == name).label;
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
      await HomeWidgetBridge.syncWidget(ref);
      if (!context.mounted) return;
      if (status == PrayerStatus.completed) {
        AppSnackBar.success(context, AppStrings.namazMarkedSuccess);
      } else {
        AppSnackBar.success(context, 'Recorded as missed. Stay steadfast.');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not save. Try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final mapAsync = ref.watch(todayFardMapProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return mapAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (map) {
        final scheme = Theme.of(context).colorScheme;
        return JaizaSurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.today_outlined, color: scheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jaiza · Today\'s Prayers',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...kJaizaStripPrayerNames.map((name) {
                final log = map[name];
                final status = log?.status;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _label(name),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          status == PrayerStatus.completed
                              ? 'Prayed'
                              : status == PrayerStatus.missed
                                  ? 'Missed'
                                  : 'Not recorded',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: status == PrayerStatus.completed
                                    ? scheme.primary
                                    : status == PrayerStatus.missed
                                        ? scheme.error
                                        : scheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.primary,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 20),
                        tooltip: 'Mark as prayed',
                        onPressed: () => _mark(context, ref, uid, name, PrayerStatus.completed),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'Missed',
                        onPressed: () => _mark(context, ref, uid, name, PrayerStatus.missed),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
