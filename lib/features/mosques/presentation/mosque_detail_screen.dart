import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/mosque_data.dart';

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
      return const Center(child: Text('Mosque not found'));
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
                      '${mosque.address} · ${mosque.distanceLabel}',
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
                  Expanded(child: Text('Jama’at times', style: t.titleMedium)),
                  JzChip(mosque.fiqh),
                ],
              ),
              const SizedBox(height: 8),
              for (final def in kFardPrayerDefs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(def.label, style: t.bodyLarge)),
                      Text(
                        mosque
                            .longTime(def.name)
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
                      text: 'Times wrong? ',
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => AppSnackBar.success(
                              context,
                              'Thanks — the Al Islaah team will check these times.',
                            ),
                            child: Text(
                              'Report them',
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
                title: 'My primary mosque',
                subtitle: 'Its times show on your Today screen',
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
                title: 'In favourites',
                value: saved,
                onChanged: (v) => ref
                    .read(savedMosqueIdsProvider.notifier)
                    .toggle(mosque.id, v),
              ),
              const JzDivider(),
              JzSwitchRow(
                title: 'Alert before Jama’at',
                subtitle: '$minutes minutes before',
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
