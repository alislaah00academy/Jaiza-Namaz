import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../home/presentation/prayer_marking.dart';
import '../../parent/data/family_data.dart';
import '../../qaza/data/qaza_tracker.dart';

/// One student: today's five prayers (mark straight from here too), this
/// month's summary, Qaza owed, and a link into their full history.
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });

  final String classId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    final students = orgId == null
        ? const []
        : ref
                  .watch(
                    studentsForClassProvider((orgId: orgId, classId: classId)),
                  )
                  .valueOrNull ??
              const [];
    final matches = students.where((s) => s.id == studentId);
    final student = matches.isEmpty ? null : matches.first;

    final logs =
        ref.watch(personFardLogsProvider(studentId)).valueOrNull ?? const [];
    final now = DateTime.now();
    final todayMap = logsOnDay(logs, now);
    final doneToday = fardDoneOn(logs, now);
    final (streak, _) = fardStreak(logs);
    final createdAt = student?.createdAt;
    final since = createdAt == null
        ? ref.watch(qazaTrackingSinceProvider)
        : DateTime(createdAt.year, createdAt.month, createdAt.day);
    final overview = buildQazaOverview(
      since: since,
      fardLogs: logs,
      qazaLogs:
          ref.watch(personQazaLogsProvider(studentId)).valueOrNull ?? const [],
      schedule: ref.watch(currentPrayerCardProvider).valueOrNull?.today,
    );

    final monthLogs = logs.where((l) {
      final d = l.dateTime.toLocal();
      return d.year == now.year &&
          d.month == now.month &&
          l.status == PrayerStatus.completed;
    }).length;
    final possible = now.day * kFardPrayerDefs.length;
    final pct = possible == 0 ? 0 : (monthLogs * 100 / possible).round();
    final fullDays = fullFardDayKeysForMonth(
      logs,
      DateTime(now.year, now.month),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              LetterAvatarLikeBig(student?.name ?? '?'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student?.name ?? 'Student', style: t.titleMedium),
                    Text(
                      student?.createdAt == null
                          ? 'Added recently'
                          : 'Added ${DateFormat('d MMMM').format(student!.createdAt!)}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.local_fire_department_outlined,
                size: 18,
                color: c.tertiary,
              ),
              const SizedBox(width: 4),
              Text('$streak', style: t.titleSmall),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('Today', style: t.titleMedium)),
                    JzChip('$doneToday / ${kFardPrayerDefs.length}'),
                  ],
                ),
              ),
              Divider(height: 1, color: c.outlineVariant),
              for (var i = 0; i < kFardPrayerDefs.length; i++)
                Builder(
                  builder: (context) {
                    final def = kFardPrayerDefs[i];
                    final done =
                        todayMap[def.name]?.status == PrayerStatus.completed;
                    return JzPrayerRow(
                      name: def.label,
                      checked: done,
                      showDivider: i < kFardPrayerDefs.length - 1,
                      onToggle: () => togglePrayer(
                        context,
                        ref,
                        name: def.name,
                        label: def.label,
                        type: PrayerType.fard,
                        currentlyDone: done,
                        personId: studentId,
                      ),
                    );
                  },
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
                  Expanded(child: Text('This month', style: t.titleMedium)),
                  Text('$monthLogs / $possible', style: t.titleSmall),
                ],
              ),
              const SizedBox(height: 8),
              JzBar(value: possible == 0 ? 0 : monthLogs / possible),
              const SizedBox(height: 6),
              Text(
                '$pct% on time · ${fullDays.length} complete ${fullDays.length == 1 ? 'day' : 'days'}',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        JzStripCard(
          margin: EdgeInsets.zero,
          icon: Icons.history_edu_outlined,
          title: 'Qaza',
          subtitle: overview.remaining == 0
              ? 'Nothing to make up'
              : '${overview.remaining} to make up · since ${DateFormat('d MMMM').format(overview.since)}',
        ),
        const SizedBox(height: 12),
        JzCard(
          padding: const EdgeInsets.all(16),
          onTap: () =>
              _showFullHistory(context, student?.name ?? 'Student', logs),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: c.primary),
              const SizedBox(width: 12),
              Expanded(child: Text('Full history', style: t.titleSmall)),
              const JzChevron(),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullHistory(
    BuildContext context,
    String name,
    List<PrayerLog> logs,
  ) {
    final byDay = <String, int>{};
    for (final l in logs) {
      if (l.status != PrayerStatus.completed) continue;
      final key = l.dateTime.toLocal().toString().split(' ').first;
      byDay[key] = (byDay[key] ?? 0) + 1;
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    showJzSheet<void>(
      context,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('$name — full history', style: t.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: days.isEmpty
                    ? Center(
                        child: Text(
                          'No prayers logged yet.',
                          style: t.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: days.length,
                        itemBuilder: (context, i) {
                          final day = days[i];
                          return ListTile(
                            dense: true,
                            title: Text(
                              DateFormat(
                                'EEEE, d MMMM',
                              ).format(DateTime.parse(day)),
                            ),
                            trailing: Text(
                              '${byDay[day]}/${kFardPrayerDefs.length}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LetterAvatarLikeBig extends StatelessWidget {
  const LetterAvatarLikeBig(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.secondaryContainer,
      ),
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: c.secondary,
          fontSize: 20,
        ),
      ),
    );
  }
}
