import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Mark today's Fard prayers for one student and browse their full history.
class StudentHistoryScreen extends ConsumerWidget {
  const StudentHistoryScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });

  final String classId;
  final String studentId;

  Future<void> _mark(WidgetRef ref, PrayerName name, PrayerStatus status) async {
    final appUser = ref.read(appUserStreamProvider).valueOrNull;
    final teacherUid = appUser?.uid;
    if (teacherUid == null) return;
    await ref.read(prayerRepositoryProvider).upsertPrayer(
          userId: studentId,
          prayerName: name,
          type: PrayerType.fard,
          status: status,
          ownerUid: teacherUid,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgId = ref.watch(appUserStreamProvider).valueOrNull?.orgId;
    final studentsAsync = orgId == null
        ? null
        : ref.watch(studentsForClassProvider((orgId: orgId, classId: classId)));
    final student = studentsAsync?.valueOrNull
        ?.where((s) => s.id == studentId)
        .toList();
    final studentName =
        (student != null && student.isNotEmpty) ? student.first.name : 'Student';

    final fardMapAsync = ref.watch(studentTodayFardMapProvider(studentId));
    final allFardAsync = ref.watch(childAllFardProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text(studentName)),
      body: fardMapAsync.when(
        data: (map) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Today', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final def in kFardPrayerDefs)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(def.label),
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
            const SizedBox(height: 16),
            Text('History', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            allFardAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Text('No prayers logged yet.');
                }
                final byDay = <String, int>{};
                for (final log in logs) {
                  if (log.status != PrayerStatus.completed) continue;
                  final key = AppDateUtils.localDateKey(log.dateTime);
                  byDay[key] = (byDay[key] ?? 0) + 1;
                }
                final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
                return Column(
                  children: [
                    for (final day in days.take(30))
                      ListTile(
                        dense: true,
                        title: Text(day),
                        trailing: Text('${byDay[day]}/${kFardPrayerDefs.length}'),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Could not load history: $e'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load attendance: $e')),
      ),
    );
  }
}
