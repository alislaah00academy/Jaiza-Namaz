import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../../services/location_service.dart';
import '../../../services/prayer_times_service.dart';
import '../../home/presentation/prayer_marking.dart';
import '../../parent/data/family_data.dart';
import '../../parent/presentation/family_widgets.dart';

/// Prayer schedule for any local day (same location rules as Today, using
/// the last cached GPS fix instead of asking for a new one).
final _scheduleForDayProvider = FutureProvider.autoDispose
    .family<DailyPrayerSchedule, DateTime>((ref, day) async {
      final s = ref.watch(prayerSettingsProvider);
      var lat = s.manualLat;
      var lon = s.manualLon;
      if (s.useGps) {
        try {
          final cached = await LocationService.readCachedCoords();
          if (cached != null) {
            lat = cached.lat;
            lon = cached.lon;
          }
        } catch (_) {}
      }
      return PrayerTimesService.forLocalDay(
        localDay: day,
        latitude: lat,
        longitude: lon,
        settings: s,
      );
    });

/// Records — one calendar for every prayer type; past days are editable.
/// For a Parent, the chip row switches whose records are shown.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _selected = DateTime(n.year, n.month, n.day);
    _month = DateTime(n.year, n.month);
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      final last = DateTime(_month.year, _month.month + 1, 0).day;
      final day = _selected.day.clamp(1, last);
      final candidate = DateTime(_month.year, _month.month, day);
      _selected = candidate.isAfter(_today) ? _today : candidate;
      if (_selected.month != _month.month) {
        _selected = DateTime(_month.year, _month.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isParent = ref.watch(isParentProvider);
    final me = ref.watch(currentUserProvider)?.uid;
    final childId = isParent ? ref.watch(selectedChildIdProvider) : null;
    final uid = childId ?? me;
    final canGoForward = DateTime(
      _month.year,
      _month.month + 1,
    ).isBefore(DateTime(_today.year, _today.month + 1));

    if (uid == null) return const SizedBox.shrink();

    final fardLogs = ref.watch(personFardLogsProvider(uid)).valueOrNull ?? const [];
    final nawafilLogs =
        ref.watch(personNawafilLogsProvider(uid)).valueOrNull ?? const [];
    final qazaLogs = ref.watch(personQazaLogsProvider(uid)).valueOrNull ?? const [];
    final full = fullFardDayKeysForMonth(fardLogs, _month);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const JzPageTitle('Records'),
        if (isParent) const PersonChipRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JzCard(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => _shiftMonth(-1),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('MMMM y').format(_month),
                            textAlign: TextAlign.center,
                            style: t.titleSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: canGoForward ? () => _shiftMonth(1) : null,
                        ),
                      ],
                    ),
                    _MonthGrid(
                      month: _month,
                      selected: _selected,
                      today: _today,
                      fullDays: full,
                      onSelect: (d) => setState(() => _selected = d),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DayFardCard(
                day: _selected,
                today: _today,
                personId: childId,
                logs: fardLogs,
              ),
              const SizedBox(height: 14),
              _DayNawafilCard(
                day: _selected,
                today: _today,
                personId: childId,
                logs: nawafilLogs,
                trackingOn: childId != null ||
                    (ref.watch(appUserStreamProvider).valueOrNull?.nawafilEnabled ??
                        false),
              ),
              _DayQazaCard(day: _selected, logs: qazaLogs),
              const SizedBox(height: 14),
              _MonthSummary(
                month: _month,
                today: _today,
                logs: fardLogs,
                fullDays: full,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.today,
    required this.fullDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final Set<String> fullDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month, 1).weekday - 1; // Mon=0
    const dows = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final cells = <Widget>[
      for (final d in dows)
        Center(
          child: Text(
            d,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.onSurfaceVariant,
            ),
          ),
        ),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var day = 1; day <= days; day++)
        Builder(
          builder: (context) {
            final date = DateTime(month.year, month.month, day);
            final isSel = date == selected;
            final isToday = date == today;
            final future = date.isAfter(today);
            final dot = fullDays.contains(AppDateUtils.localDateKey(date));
            return InkWell(
              customBorder: const CircleBorder(),
              onTap: future ? null : () => onSelect(date),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel
                      ? c.primary
                      : isToday
                      ? c.primaryContainer.withValues(alpha: 0.45)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel || isToday
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSel
                            ? c.onPrimary
                            : future
                            ? c.onSurfaceVariant.withValues(alpha: 0.5)
                            : c.onSurface,
                      ),
                    ),
                    if (dot && !isSel)
                      Positioned(
                        bottom: 3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.tertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 1.1,
      children: cells,
    );
  }
}

class _DayFardCard extends ConsumerWidget {
  const _DayFardCard({
    required this.day,
    required this.today,
    required this.logs,
    this.personId,
  });

  final DateTime day;
  final DateTime today;
  final List<PrayerLog> logs;
  final String? personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final map = logsOnDay(logs, day);
    final schedule = ref.watch(_scheduleForDayProvider(day)).valueOrNull;
    final now = DateTime.now();
    final done = kFardPrayerDefs
        .where((d) => map[d.name]?.status == PrayerStatus.completed)
        .length;
    // Records edits land at noon so they never slip into a neighbouring day.
    final at = day == today ? null : DateTime(day.year, day.month, day.day, 12);
    return JzCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d MMMM').format(day),
                    style: t.titleMedium,
                  ),
                ),
                JzChip('$done / ${kFardPrayerDefs.length}'),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          for (var i = 0; i < kFardPrayerDefs.length; i++)
            Builder(
              builder: (context) {
                final def = kFardPrayerDefs[i];
                final log = map[def.name];
                final isDone = log?.status == PrayerStatus.completed;
                final start = schedule?.startTimeFor(def.name);
                final end = schedule?.endTimeFor(def.name);
                final ended =
                    day.isBefore(today) || (end != null && end.isBefore(now));
                final missed = !isDone && ended;
                return JzPrayerRow(
                  name: def.label,
                  checked: isDone,
                  state: missed ? JzRowState.missed : JzRowState.normal,
                  sub: missed
                      ? null
                      : start == null
                      ? def.startHint
                      : DateFormat('h:mm a').format(start),
                  subWidget: !missed
                      ? null
                      : log?.status == PrayerStatus.missed
                      ? Text(
                          personId == null
                              ? 'Missed · in your Qaza list'
                              : 'Missed · in the Qaza list',
                          style: t.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : MissedAddToQaza(
                          onAdd: () => addMissedToQaza(
                            context,
                            ref,
                            name: def.name,
                            label: def.label,
                            at: at,
                            personId: personId,
                          ),
                        ),
                  showDivider: i < kFardPrayerDefs.length - 1,
                  onToggle: () => togglePrayer(
                    context,
                    ref,
                    name: def.name,
                    label: def.label,
                    type: PrayerType.fard,
                    currentlyDone: isDone,
                    at: at,
                    personId: personId,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DayNawafilCard extends ConsumerWidget {
  const _DayNawafilCard({
    required this.day,
    required this.today,
    required this.logs,
    required this.trackingOn,
    this.personId,
  });

  final DateTime day;
  final DateTime today;
  final List<PrayerLog> logs;
  final bool trackingOn;
  final String? personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final map = logsOnDay(logs, day);
    if (!trackingOn && map.isEmpty) return const SizedBox.shrink();
    final done = kNawafilDefs
        .where((d) => map[d.name]?.status == PrayerStatus.completed)
        .length;
    final at = day == today ? null : DateTime(day.year, day.month, day.day, 12);
    return JzCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.front_hand_outlined, color: c.primary),
                const SizedBox(width: 10),
                Expanded(child: Text('Nawafil', style: t.titleMedium)),
                JzChip('$done / ${kNawafilDefs.length}'),
              ],
            ),
          ),
          Divider(height: 1, color: c.outlineVariant),
          for (var i = 0; i < kNawafilDefs.length; i++)
            Builder(
              builder: (context) {
                final def = kNawafilDefs[i];
                final isDone = map[def.name]?.status == PrayerStatus.completed;
                return JzPrayerRow(
                  name: def.label,
                  checked: isDone,
                  showDivider: i < kNawafilDefs.length - 1,
                  onToggle: () => togglePrayer(
                    context,
                    ref,
                    name: def.name,
                    label: def.label,
                    type: PrayerType.nawafil,
                    currentlyDone: isDone,
                    at: at,
                    personId: personId,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DayQazaCard extends StatelessWidget {
  const _DayQazaCard({required this.day, required this.logs});

  final DateTime day;
  final List<PrayerLog> logs;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final key = AppDateUtils.localDateKey(day);
    final n = logs
        .where(
          (l) =>
              AppDateUtils.localDateKey(l.dateTime) == key &&
              l.status == PrayerStatus.completed,
        )
        .length;
    return JzCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.history_edu_outlined, color: c.primary),
          const SizedBox(width: 12),
          Expanded(child: Text('Qaza', style: t.titleSmall)),
          Text('$n completed', style: t.labelMedium),
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.month,
    required this.today,
    required this.logs,
    required this.fullDays,
  });

  final DateTime month;
  final DateTime today;
  final List<PrayerLog> logs;
  final Set<String> fullDays;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final prayed = logs.where((l) {
      final d = l.dateTime.toLocal();
      return d.year == month.year &&
          d.month == month.month &&
          l.status == PrayerStatus.completed &&
          kFardPrayerDefs.any((f) => f.name == l.prayerName);
    }).length;
    final isCurrent = month.year == today.year && month.month == today.month;
    final daysSoFar = isCurrent
        ? today.day
        : DateTime(month.year, month.month + 1, 0).day;
    final possible = daysSoFar * kFardPrayerDefs.length;
    final pct = possible == 0 ? 0 : (prayed * 100 / possible).round();
    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${DateFormat('MMMM').format(month)} summary',
                  style: t.titleMedium,
                ),
              ),
              Text('$prayed / $possible', style: t.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          JzBar(value: possible == 0 ? 0 : prayed / possible, height: 8),
          const SizedBox(height: 8),
          Text(
            '$pct% prayed · ${fullDays.length} complete '
            '${fullDays.length == 1 ? 'day' : 'days'}',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
