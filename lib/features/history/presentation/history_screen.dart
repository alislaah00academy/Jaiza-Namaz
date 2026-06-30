import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/constants/prayer_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Unified history: one calendar, with Fard, Nawafil, and Qaza status for
/// the selected day shown together — replaces having to check three
/// separate screens for past records.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focusedDay = DateTime(n.year, n.month, n.day);
    _selectedDay = _focusedDay;
  }

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateLabel(DateTime d) => AppDateUtils.localDateKey(d);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monthAnchor = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final fullFardDays = ref.watch(
      fullFardDayKeysForMonthProvider(monthAnchor),
    );
    final fardMap = ref.watch(fardMapForDateProvider(_selectedDay));
    final nawafilMap = ref.watch(nawafilMapForDateProvider(_selectedDay));
    final qazaLogs = ref.watch(qazaLogsForDateProvider(_selectedDay));
    final qazaCompleted = qazaLogs
        .where((l) => l.status == PrayerStatus.completed)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dateLabel(_selectedDay),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TableCalendar<void>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                eventLoader: (day) {
                  final k = AppDateUtils.localDateKey(day);
                  if (fullFardDays.contains(k)) return [null];
                  return [];
                },
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = _norm(selected);
                    _focusedDay = _norm(focused);
                  });
                },
                onPageChanged: (focused) {
                  setState(() => _focusedDay = focused);
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: scheme.onSurfaceVariant),
                  todayDecoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: scheme.onPrimary),
                  todayTextStyle: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: scheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: textTheme.titleSmall ?? const TextStyle(),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: scheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: scheme.primary,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _HistorySection(
          title: 'Obligatory (Fard)',
          rows: [
            for (final def in kFardPrayerDefs)
              _StatusRow(label: def.label, status: fardMap[def.name]?.status),
          ],
        ).jaizaEnter(index: 1),
        const SizedBox(height: 12),
        _HistorySection(
          title: 'Nawafil',
          rows: [
            for (final def in kNawafilDefs)
              _StatusRow(
                label: def.label,
                status: nawafilMap[def.name]?.status,
              ),
          ],
        ).jaizaEnter(index: 2),
        const SizedBox(height: 12),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.history_edu_outlined, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Qaza',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$qazaCompleted completed',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ).jaizaEnter(index: 3),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.title, required this.rows});

  final String title;
  final List<_StatusRow> rows;

  @override
  Widget build(BuildContext context) {
    return JaizaSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.status});

  final String label;
  final PrayerStatus? status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final icon = status == PrayerStatus.completed
        ? Icon(Icons.check_circle, color: scheme.primary)
        : status == PrayerStatus.missed
        ? Icon(Icons.nightlight_round, color: scheme.error)
        : Icon(Icons.circle_outlined, color: scheme.outline);
    final chipLabel = status == PrayerStatus.completed
        ? 'Prayed'
        : status == PrayerStatus.missed
        ? 'Missed'
        : 'Not recorded';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 30, child: icon),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTokens.radiusChip),
            ),
            child: Text(
              chipLabel,
              style: textTheme.labelSmall?.copyWith(
                color: status == PrayerStatus.completed
                    ? scheme.primary
                    : status == PrayerStatus.missed
                    ? scheme.error
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
