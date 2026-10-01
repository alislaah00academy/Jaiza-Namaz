import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/prayer_enums.dart';

part 'daily_summary.freezed.dart';
part 'daily_summary.g.dart';

/// `{subject}/dailySummaries/{dateKey}` (06 §2.3) — Function-written (D-071).
/// Records/calendar screens read one month of these (≤ 31 small docs)
/// instead of every log.
@freezed
abstract class DailySummary with _$DailySummary {
  const factory DailySummary({
    required String dateKey,
    @Default(0) int fardDone,
    @Default(0) int fardMissed,
    @Default(0) int fardUnmarked,

    /// Keyed by [PrayerName.name] (`fajr`…`isha`); value is `null` when that
    /// prayer isn't marked yet. (`unknownEnumValue` isn't supported on a Map
    /// value by json_serializable — Functions only ever write `completed`/
    /// `missed`/absent, so this is safe.)
    @Default({}) Map<String, PrayerStatus?> fard,
    @Default(0) int nawafilDone,
    @Default(0) int qazaDone,

    /// All 5 Fard `completed` for this [dateKey] (09 §5 "perfect day").
    @Default(false) bool perfect,
    DateTime? updatedAt,
  }) = _DailySummary;

  factory DailySummary.fromJson(Map<String, dynamic> json) =>
      _$DailySummaryFromJson(json);
}
