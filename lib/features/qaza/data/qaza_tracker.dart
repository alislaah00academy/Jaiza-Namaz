import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local/local_prefs.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../../services/prayer_times_service.dart';
import 'qaza_plan.dart';

/// One prayer's Qaza picture: prayers Jaiza counted as missed (with dates),
/// the user's own pre-Jaiza estimate, and how many have been made up.
///
/// Everything is derived client-side from data that already exists — Fard
/// logs, Qaza logs and `qazaPlan` — so no new backend is needed. A Fard
/// prayer counts as missed once its window has ended without a
/// "completed" log.
class QazaPrayerSummary {
  const QazaPrayerSummary({
    required this.prayer,
    required this.trackedMissed,
    required this.estimate,
    required this.completedDates,
  });

  final PrayerName prayer;

  /// Days on which this prayer was missed since tracking began, oldest first.
  final List<DateTime> trackedMissed;

  /// Pre-Jaiza estimate (0 when none was entered).
  final int estimate;

  /// Dates on which a Qaza of this prayer was recorded as made up, oldest
  /// first.
  final List<DateTime> completedDates;

  int get total => trackedMissed.length + estimate;
  int get completed => completedDates.length;
  int get remaining => (total - completed).clamp(0, 1 << 30);

  /// Made-up Qaza are applied to Jaiza-tracked days first (oldest first),
  /// then to the estimate. Returns the make-up date for the tracked day at
  /// [index] in [trackedMissed], or null if it is still owed.
  DateTime? madeUpOn(int index) =>
      index < completedDates.length ? completedDates[index] : null;

  int get trackedRemaining =>
      (trackedMissed.length - completed).clamp(0, trackedMissed.length);

  int get estimateRemaining {
    final leftover = (completed - trackedMissed.length).clamp(0, 1 << 30);
    return (estimate - leftover).clamp(0, estimate);
  }
}

class QazaOverview {
  const QazaOverview({
    required this.since,
    required this.byPrayer,
    required this.hasEstimate,
    required this.dailyGoal,
  });

  final DateTime since;
  final Map<PrayerName, QazaPrayerSummary> byPrayer;
  final bool hasEstimate;
  final int dailyGoal;

  int get trackedTotal =>
      byPrayer.values.fold(0, (s, p) => s + p.trackedMissed.length);
  int get estimateTotal => byPrayer.values.fold(0, (s, p) => s + p.estimate);
  int get total => trackedTotal + estimateTotal;
  int get completed => byPrayer.values.fold(0, (s, p) => s + p.completed);
  int get remaining => byPrayer.values.fold(0, (s, p) => s + p.remaining);

  /// Days needed at [dailyGoal] a day to clear [remaining].
  int get daysToFinish => dailyGoal <= 0 ? 0 : (remaining / dailyGoal).ceil();
}

/// "2 years 1 month" style label for a span of days.
String qazaDurationLabel(int days) {
  if (days <= 0) return '0 days';
  final years = days ~/ 365;
  final months = (days % 365) ~/ 30;
  final rest = days % 365 % 30;
  final parts = <String>[
    if (years > 0) '$years ${years == 1 ? 'year' : 'years'}',
    if (months > 0) '$months ${months == 1 ? 'month' : 'months'}',
    if (years == 0 && months == 0) '$rest ${rest == 1 ? 'day' : 'days'}',
  ];
  return parts.join(' ');
}

/// Date tracking started — see [localTrackingSinceProvider].
final qazaTrackingSinceProvider = Provider<DateTime>(
  (ref) => ref.watch(localTrackingSinceProvider),
);

final qazaOverviewProvider = Provider<QazaOverview>((ref) {
  final user = ref.watch(appUserStreamProvider).valueOrNull;
  final plan = user?.qazaPlanParsed ?? QazaPlanParsed.defaults();
  return buildQazaOverview(
    since: ref.watch(qazaTrackingSinceProvider),
    fardLogs: ref.watch(userFardLogsProvider).valueOrNull ?? const [],
    qazaLogs: ref.watch(userQazaLogsProvider).valueOrNull ?? const [],
    schedule: ref.watch(currentPrayerCardProvider).valueOrNull?.today,
    estimates: {
      if (plan.setupComplete)
        for (final p in kQazaPrayerNames) p: plan.backlogFor(p).totalDays,
    },
    dailyGoal: user?.qazaDailyTarget ?? 1,
  );
});

/// Builds a [QazaOverview] from raw logs — shared by the signed-in user and
/// the children a parent tracks. A Fard prayer is missed once its window
/// ended with no "completed" log on or after [since].
QazaOverview buildQazaOverview({
  required DateTime since,
  required List<PrayerLog> fardLogs,
  required List<PrayerLog> qazaLogs,
  required DailyPrayerSchedule? schedule,
  Map<PrayerName, int> estimates = const {},
  int dailyGoal = 1,
}) {
  final prayedKeys = <String>{
    for (final l in fardLogs)
      if (l.status == PrayerStatus.completed)
        '${AppDateUtils.localDateKey(l.dateTime)}|${l.prayerName.name}',
  };

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(since.year, since.month, since.day);

  final missed = {for (final p in kQazaPrayerNames) p: <DateTime>[]};
  for (
    var d = start;
    !d.isAfter(today);
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    final key = AppDateUtils.localDateKey(d);
    for (final p in kQazaPrayerNames) {
      final ended = d.isBefore(today)
          ? true
          : schedule != null && schedule.endTimeFor(p).isBefore(now);
      if (!ended) continue;
      if (!prayedKeys.contains('$key|${p.name}')) missed[p]!.add(d);
    }
  }

  final byPrayer = <PrayerName, QazaPrayerSummary>{};
  for (final p in kQazaPrayerNames) {
    final done =
        qazaLogs
            .where(
              (l) => l.prayerName == p && l.status == PrayerStatus.completed,
            )
            .map((l) => l.dateTime.toLocal())
            .toList()
          ..sort();
    byPrayer[p] = QazaPrayerSummary(
      prayer: p,
      trackedMissed: missed[p]!,
      estimate: estimates[p] ?? 0,
      completedDates: done,
    );
  }

  return QazaOverview(
    since: start,
    byPrayer: byPrayer,
    hasEstimate: estimates.isNotEmpty,
    dailyGoal: dailyGoal,
  );
}
