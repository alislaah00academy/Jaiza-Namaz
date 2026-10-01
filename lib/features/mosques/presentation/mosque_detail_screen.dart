import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/mosque_data.dart';
import '../../../core/l10n/l10n.dart';

/// One mosque: address, Jama'at times, and the primary / favourite /
/// alert switches.
class MosqueDetailScreen extends ConsumerWidget {
  const MosqueDetailScreen({super.key, required this.mosqueId});

  final String mosqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final mosque = mosqueById(mosqueId);
    if (mosque == null) {
      return Center(child: Text(context.l10n.mosqueNotFound));
    }
    final isPrimary = ref.watch(primaryMosqueIdProvider) == mosque.id;
    final saved = ref.watch(savedMosqueIdsProvider).contains(mosque.id);
    final alertMosques = ref.watch(jamaatAlertMosquesProvider);
    final alertOn = alertMosques.contains(mosque.id);
    final minutes = ref.watch(jamaatAlertMinutesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const JzAvatar(
                icon: Icons.mosque_outlined,
                size: 48,
                iconSize: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mosque.name, style: t.titleMedium),
                    Text(
                      context.l10n.dotJoin(
                        mosque.address,
                        mosque.distanceLabel(context.l10n),
                      ),
                      style: t.bodySmall,
                    ),
                  ],
                ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(context.l10n.jamaatTimes, style: t.titleMedium),
                  ),
                  JzChip(mosque.fiqhLabel(context.l10n)),
                ],
              ),
              const SizedBox(height: 8),
              for (final def in kFardPrayerDefs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(def.label(context.l10n), style: t.bodyLarge),
                      ),
                      Text(
                        mosque
                            .longTime(def.name, context.l10n)
                            .replaceFirst(RegExp('^0'), ''),
                        style: t.titleSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: c.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      text: context.l10n.timesWrong,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => AppSnackBar.success(
                              context,
                              context.l10n.reportThanks,
                            ),
                            child: Text(
                              context.l10n.reportThem,
                              style: t.bodySmall?.copyWith(
                                color: c.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: c.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    style: t.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              JzSwitchRow(
                title: context.l10n.myPrimaryMosque,
                subtitle: context.l10n.myPrimaryMosqueSubtitle,
                value: isPrimary,
                onChanged: (v) {
                  ref
                      .read(primaryMosqueIdProvider.notifier)
                      .set(v ? mosque.id : null);
                  if (v) {
                    ref
                        .read(jamaatAlertMosquesProvider.notifier)
                        .toggle(mosque.id, true);
                  }
                },
              ),
              const JzDivider(),
              JzSwitchRow(
                title: context.l10n.inFavourites,
                value: saved,
                onChanged: (v) => ref
                    .read(savedMosqueIdsProvider.notifier)
                    .toggle(mosque.id, v),
              ),
              const JzDivider(),
              JzSwitchRow(
                title: context.l10n.alertBeforeJamaat,
                subtitle: context.l10n.minutesBefore(minutes),
                value: alertOn,
                onChanged: (v) => ref
                    .read(jamaatAlertMosquesProvider.notifier)
                    .toggle(mosque.id, v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
