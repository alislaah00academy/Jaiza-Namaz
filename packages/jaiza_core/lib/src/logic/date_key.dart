import '../enums/prayer_enums.dart';

/// `dateKey` helpers — a `YYYY-MM-DD` string in the subject's local calendar
/// (06 §2.2, 09 §2). Cloud Functions have a matching `dateKey.ts`; keep both
/// in sync (shared fixtures, 18 §4).
///
/// All functions here use the calendar fields of the [DateTime] they get
/// (after `toLocal()`), so they never depend on a time zone database.
abstract final class DateKeys {
  /// How many days back a prayer may still be marked or changed: today and the
  /// previous 7 days (D-075).
  static const int markableDaysBack = 7;

  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// `YYYY-MM-DD` of [d] in local time.
  static String of(DateTime d) {
    final l = d.toLocal();
    return '${_pad(l.year, 4)}-${_pad(l.month, 2)}-${_pad(l.day, 2)}';
  }

  /// `YYYY-MM` of [d] in local time (month pages, `dailySummaries` ranges).
  static String monthOf(DateTime d) {
    final l = d.toLocal();
    return '${_pad(l.year, 4)}-${_pad(l.month, 2)}';
  }

  /// Local midnight of [key]. Throws [FormatException] for anything that is
  /// not a real calendar date (e.g. `2026-02-30`).
  static DateTime parse(String key) {
    final m = _pattern.firstMatch(key);
    if (m == null) throw FormatException('Not a dateKey', key);
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final date = DateTime(y, mo, d);
    if (date.year != y || date.month != mo || date.day != d) {
      throw FormatException('Not a calendar date', key);
    }
    return date;
  }

  static bool isValid(String key) {
    try {
      parse(key);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// [key] moved by [days] calendar days (negative = back). Uses calendar
  /// arithmetic, so DST changes never skip or repeat a day.
  static String addDays(String key, int days) {
    final d = parse(key);
    return of(DateTime(d.year, d.month, d.day + days));
  }

  /// Whole calendar days from [from] to [to] (positive when [to] is later).
  static int daysBetween(String from, String to) {
    final a = parse(from);
    final b = parse(to);
    return DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;
  }

  /// The prayer day a mark made at [now] belongs to (09 §2). The prayer day
  /// starts at Fajr: Isha, Witr or Tahajjud marked after midnight but before
  /// [todayFajr] belong to **yesterday**. Every other prayer uses today.
  static String forPrayer({
    required PrayerName prayer,
    required DateTime now,
    required DateTime todayFajr,
  }) {
    final today = of(now);
    if (prayer.belongsToPreviousDayBeforeFajr && now.isBefore(todayFajr)) {
      return addDays(today, -1);
    }
    return today;
  }

  /// Whether a log for [key] may be written at [now]: today or up to
  /// [markableDaysBack] days back, never the future (D-075, rules enforce it
  /// too).
  static bool isMarkable(String key, {required DateTime now}) {
    if (!isValid(key)) return false;
    final diff = daysBetween(key, of(now));
    return diff >= 0 && diff <= markableDaysBack;
  }

  static String _pad(int v, int width) => v.toString().padLeft(width, '0');
}
