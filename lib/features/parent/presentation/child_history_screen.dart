import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Full Fard history for one child, grouped by local day (most recent first).
class ChildHistoryScreen extends ConsumerWidget {
  const ChildHistoryScreen({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(childAllFardProvider(childId));
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No prayers logged yet.'));
          }
          final byDay = <String, List<PrayerLog>>{};
          for (final log in logs) {
            final key = AppDateUtils.localDateKey(log.dateTime);
            byDay.putIfAbsent(key, () => []).add(log);
          }
          final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final dayLogs = byDay[day]!;
              final completed = dayLogs
                  .where((l) => l.status == PrayerStatus.completed)
                  .length;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(day),
                  subtitle: Text('$completed/${kFardPrayerDefs.length} completed'),
                  children: [
                    for (final def in kFardPrayerDefs)
                      ListTile(
                        dense: true,
                        title: Text(def.label),
                        trailing: _statusIcon(
                          dayLogs
                              .where((l) => l.prayerName == def.name)
                              .map((l) => l.status)
                              .firstOrNullSafe,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load history: $e')),
      ),
    );
  }

  Widget _statusIcon(PrayerStatus? status) {
    if (status == PrayerStatus.completed) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (status == PrayerStatus.missed) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    return const Icon(Icons.remove_circle_outline, color: Colors.grey);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNullSafe {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
