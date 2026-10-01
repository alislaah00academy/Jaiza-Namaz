import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaiza_core/jaiza_core.dart';

/// Calendar helpers for prayer queries and streaks (local device timezone).
class AppDateUtils {
  AppDateUtils._();

  /// Start of local calendar day.
  static DateTime startOfLocalDay(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime endOfLocalDay(DateTime d) {
    return startOfLocalDay(d).add(const Duration(days: 1));
  }

  /// `yyyy-MM-dd` in local time for streak bookkeeping.
  static String localDateKey(DateTime d) => DateKeys.of(d);

  static Timestamp dateTimeToTimestampUtc(DateTime d) {
    return Timestamp.fromDate(d.toUtc());
  }

  static DateTime timestampToLocalDateTime(Timestamp t) {
    return t.toDate().toLocal();
  }
}
