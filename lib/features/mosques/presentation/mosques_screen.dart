import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/mosque_data.dart';
import 'mosque_widgets.dart';
import '../../../core/l10n/l10n.dart';

/// Mosques tab: search, register, the primary mosque with its Jama'at
/// times, then saved and nearby lists.
class MosquesScreen extends ConsumerWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final all = ref.watch(mosquesProvider);
    final primary = ref.watch(primaryMosqueProvider);
    final savedIds = ref.watch(savedMosqueIdsProvider);
    final saved = all
        .where((m) => savedIds.contains(m.id) && m.id != primary?.id)
        .toList();
    final nearby = all
        .where((m) => !savedIds.contains(m.id) && m.id != primary?.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        JzPageTitle(context.l10n.titleMosques),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: JzSearchBar(
            readOnly: true,
            onTap: () => context.push('/app/mosques/search'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: RegisterMosqueAction(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JzSectionLabel(context.l10n.yourMosque),
              if (primary != null)
                _PrimaryCard(mosque: primary)
              else
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.l10n.noPrimaryMosqueYet,
                    style: t.bodyMedium,
                  ),
                ),
              if (saved.isNotEmpty) ...[
                const SizedBox(height: 20),
                JzSectionLabel(
                  context.l10n.savedSection,
                  trailing: context.l10n.tapStarToRemove,
                ),
                MosqueListCard(mosques: saved),
              ],
              if (nearby.isNotEmpty) ...[
                const SizedBox(height: 20),
                JzSectionLabel(
                  context.l10n.nearbySection,
                  trailing: context.l10n.tapStarToSave,
                ),
                MosqueListCard(mosques: nearby),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  const _PrimaryCard({required this.mosque});

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return JzCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/app/mosques/${mosque.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const JzAvatar(
                icon: Icons.mosque_outlined,
                size: 44,
                iconSize: 22,
                tone: JzAvatarTone.gold,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mosque.name, style: t.titleMedium),
                    Text(mosque.subtitle(context.l10n), style: t.bodySmall),
                  ],
                ),
              ),
              JzChip(context.l10n.primaryBadge, gold: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.primaryMosqueTimesNote,
            style: t.bodySmall,
          ),
          const JzDivider(),
          Row(
            children: [
              for (final def in kFardPrayerDefs)
                Expanded(
                  child: Column(
                    children: [
                      Text(def.label(context.l10n), style: t.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        mosque.shortTime(def.name),
                        style: t.titleSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
