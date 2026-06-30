import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Mark today's Fard prayers for one child. Reuses [PrayerRepository]
/// unmodified, passing the child's id in place of a Firebase uid and the
/// parent's uid as [PrayerLog.ownerUid].
class ChildAttendanceScreen extends ConsumerWidget {
  const ChildAttendanceScreen({super.key, required this.childId});

  final String childId;

  Future<void> _mark(
    WidgetRef ref,
    PrayerName name,
    PrayerStatus status,
  ) async {
    final parentUid = ref.read(currentUserProvider)?.uid;
    if (parentUid == null) return;
    await ref.read(prayerRepositoryProvider).upsertPrayer(
          userId: childId,
          prayerName: name,
          type: PrayerType.fard,
          status: status,
          ownerUid: parentUid,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenStreamProvider);
    final fardMapAsync = ref.watch(childTodayFardMapProvider(childId));

    final children = childrenAsync.valueOrNull ?? const [];
    final child = children.where((c) => c.id == childId).isEmpty
        ? null
        : children.firstWhere((c) => c.id == childId);

    return Scaffold(
      appBar: AppBar(title: Text(child?.name ?? 'Mark attendance')),
      body: fardMapAsync.when(
        data: (map) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(
                'History',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  context.push('/app/parent/child/$childId/history'),
            ),
            const Divider(),
            for (final def in kFardPrayerDefs)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(def.label),
                  subtitle: Text('${def.startHint} · ${def.endHint}'),
                  trailing: SegmentedButton<PrayerStatus>(
                    segments: const [
                      ButtonSegment(
                        value: PrayerStatus.completed,
                        icon: Icon(Icons.check_circle_outline),
                      ),
                      ButtonSegment(
                        value: PrayerStatus.missed,
                        icon: Icon(Icons.close_rounded),
                      ),
                    ],
                    selected: {
                      if (map[def.name]?.status != null) map[def.name]!.status,
                    },
                    emptySelectionAllowed: true,
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      _mark(ref, def.name, selection.first);
                    },
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load attendance: $e')),
      ),
    );
  }
}
