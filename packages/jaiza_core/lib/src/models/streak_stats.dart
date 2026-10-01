import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_stats.freezed.dart';
part 'streak_stats.g.dart';

/// `{subject}/stats/streak` (06 §2.4) — Function-written and read-only for
/// clients (D-071). A "perfect day" is all 5 Fard `completed` (09 §5).
@freezed
abstract class StreakStats with _$StreakStats {
  const factory StreakStats({
    @Default(0) int current,
    @Default(0) int longest,
    String? lastPerfectDateKey,

    /// Badge ids from `kBadgeDefinitions`, e.g. `first_step`, `week_warrior`.
    /// Never removed once earned.
    @Default(<String>[]) List<String> badges,
    @Default(0) int nawafilTotal,
    DateTime? updatedAt,
  }) = _StreakStats;

  factory StreakStats.fromJson(Map<String, dynamic> json) =>
      _$StreakStatsFromJson(json);
}
