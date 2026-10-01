import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import 'date_utils.dart';

/// Hijri month names come from ARB (16 §1.1) — the `hijri` package only knows
/// English and Arabic.
String hijriMonthName(int month, L10n l) => switch (month) {
  1 => l.hijriMonth1,
  2 => l.hijriMonth2,
  3 => l.hijriMonth3,
  4 => l.hijriMonth4,
  5 => l.hijriMonth5,
  6 => l.hijriMonth6,
  7 => l.hijriMonth7,
  8 => l.hijriMonth8,
  9 => l.hijriMonth9,
  10 => l.hijriMonth10,
  11 => l.hijriMonth11,
  _ => l.hijriMonth12,
};

/// Gregorian + Hijri one-line label for widgets (local timezone).
String formatGregHijriLine(DateTime now, L10n l) {
  final local = now.toLocal();
  final greg = DateFormat('EEE, d MMM y', l.localeName).format(local);
  final h = HijriCalendar.fromDate(local);
  final hijri =
      '${h.hDay} ${hijriMonthName(h.hMonth, l)} ${h.hYear} ${l.hijriSuffix}';
  return l.dateLineSeparator(greg, hijri);
}

/// Same as [AppDateUtils.localDateKey] — `yyyy-MM-dd` in local time.
String jaizaWidgetDateKey(DateTime d) => AppDateUtils.localDateKey(d);

/// Hijri date alone, e.g. "1 Dhul Hijjah 1447".
String formatHijriDate(DateTime now, L10n l) {
  final h = HijriCalendar.fromDate(now.toLocal());
  return '${h.hDay} ${hijriMonthName(h.hMonth, l)} ${h.hYear}';
}

/// Full Gregorian date alone, e.g. "Wednesday, 28 May 2026".
String formatGregorianFull(DateTime now, L10n l) {
  return DateFormat('EEEE, d MMMM y', l.localeName).format(now.toLocal());
}
