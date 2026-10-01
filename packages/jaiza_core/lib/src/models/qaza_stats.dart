import 'package:freezed_annotation/freezed_annotation.dart';

part 'qaza_stats.freezed.dart';
part 'qaza_stats.g.dart';

/// One Fard prayer's Qaza counters inside [QazaStats.perPrayer] (06 §2.5,
/// 09 §4.3). All fields are kept incrementally by Cloud Functions.
@freezed
abstract class QazaPrayerStat with _$QazaPrayerStat {
  const QazaPrayerStat._();

  const factory QazaPrayerStat({
    /// From the user's own estimate wizard (years/months/days since
    /// puberty), per prayer — not ×5 (09 §4.1).
    @Default(0) int estimate,

    /// Fard windows since `trackingSince` that ended `missed` or unmarked.
    @Default(0) int trackedMissed,

    /// Sum of `count` on this prayer's Qaza logs.
    @Default(0) int completed,
    @Default(0) int remaining,
  }) = _QazaPrayerStat;

  factory QazaPrayerStat.fromJson(Map<String, dynamic> json) =>
      _$QazaPrayerStatFromJson(json);
}

/// `{subject}/stats/qaza` (06 §2.5) — Function-written and read-only for
/// clients (D-071).
@freezed
abstract class QazaStats with _$QazaStats {
  const factory QazaStats({
    /// Keyed by [PrayerName.name] for the 5 Fard prayers.
    @Default({}) Map<String, QazaPrayerStat> perPrayer,
    @Default(0) int totalRemaining,
    DateTime? updatedAt,
  }) = _QazaStats;

  factory QazaStats.fromJson(Map<String, dynamic> json) =>
      _$QazaStatsFromJson(json);
}
