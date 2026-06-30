import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Calendar + per-day status list for all obligatory Fard prayers.
class FardHistorySection extends ConsumerStatefulWidget {
  const FardHistorySection({super.key});

  @override
  ConsumerState<FardHistorySection> createState() => _FardHistorySectionState();
}

class _FardHistorySectionState extends ConsumerState<FardHistorySection> {
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
    final fullDays = ref.watch(fullFardDayKeysForMonthProvider(monthAnchor));
    final map = ref.watch(fardMapForDateProvider(_selectedDay));

    return JaizaSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prayer history',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a date (${_dateLabel(_selectedDay)})',
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
              if (fullDays.contains(k)) return [null];
              return [];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = _norm(selected);
                _focusedDay = _norm(focused);
              });
            },
            onPageChanged: (focused) {
              setState(() {
                _focusedDay = focused;
              });
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
              leftChevronIcon: Icon(Icons.chevron_left, color: scheme.primary),
              rightChevronIcon: Icon(Icons.chevron_right, color: scheme.primary),
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
          const SizedBox(height: 14),
          Text(
            'Status for ${_dateLabel(_selectedDay)}',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...kFardPrayerDefs.map((def) {
            final log = map[def.name];
            final status = log?.status;
            final icon = status == PrayerStatus.completed
                ? Icon(Icons.check_circle, color: scheme.primary)
                : status == PrayerStatus.missed
                    ? Icon(Icons.nightlight_round, color: scheme.error)
                    : Icon(Icons.circle_outlined, color: scheme.outline);
            final label = status == PrayerStatus.completed
                ? 'Prayed'
                : status == PrayerStatus.missed
                    ? 'Missed'
                    : 'Not recorded';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 36, child: icon),
                  Expanded(
                    child: Text(
                      def.label,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusChip),
                    ),
                    child: Text(
                      label,
                      style: textTheme.labelMedium?.copyWith(
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
          }),
        ],
      ),
    );
  }
}
