import 'package:intl/intl.dart';

import 'l10n.dart';

/// Locale-aware formatting helpers. Digits stay Latin in Urdu (16 §1.1).

/// "1h 5m", "45m", "2h" (Urdu: "1 گھنٹہ 5 منٹ" …). Negative → 0.
String formatDurationShort(Duration duration, L10n l) {
  final d = duration.isNegative ? Duration.zero : duration;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours <= 0) return l.durationMinutes(minutes);
  if (minutes == 0) return l.durationHours(hours);
  return l.durationHoursMinutes(hours, minutes);
}

/// "5:30 PM" in the app language.
String formatTime(DateTime t, L10n l) =>
    DateFormat('h:mm a', l.localeName).format(t.toLocal());

/// "05:30 PM" — fixed width, for side-by-side time cells.
String formatTimePadded(DateTime t, L10n l) =>
    DateFormat('hh:mm a', l.localeName).format(t.toLocal());

/// "28 September" in the app language.
String formatDayMonth(DateTime t, L10n l) =>
    DateFormat('d MMMM', l.localeName).format(t);
