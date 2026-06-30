import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import 'date_utils.dart';

/// Gregorian + Hijri one-line label for widgets (local timezone).
String formatGregHijriLine(DateTime now) {
  final local = now.toLocal();
  final greg = DateFormat('EEE, d MMM y').format(local);
  final h = HijriCalendar.fromDate(local);
  final hijri = '${h.hDay} ${h.longMonthName} ${h.hYear} AH';
  return '$greg · $hijri';
}

/// Same as [AppDateUtils.localDateKey] — `yyyy-MM-dd` in local time.
String jaizaWidgetDateKey(DateTime d) => AppDateUtils.localDateKey(d);

/// Hijri date alone, e.g. "1 Dhul Hijjah 1447".
String formatHijriDate(DateTime now) {
  final h = HijriCalendar.fromDate(now.toLocal());
  return '${h.hDay} ${h.longMonthName} ${h.hYear}';
}

/// Full Gregorian date alone, e.g. "Wednesday, 28 May 2026".
String formatGregorianFull(DateTime now) {
  return DateFormat('EEEE, d MMMM y').format(now.toLocal());
}
