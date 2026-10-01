import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/prayer_enums.dart';
import '../logic/prayer_log_id.dart';

part 'prayer_log.freezed.dart';
part 'prayer_log.g.dart';

/// One `{subject}/prayers/{logId}` document (06 §2.2). Same shape for
/// `users/{uid}/prayers`, `children/{id}/prayers` and `students/{id}/prayers`
/// — [SubjectRef.prayersPath] picks the collection.
@freezed
abstract class PrayerLog with _$PrayerLog {
  const PrayerLog._();

  const factory PrayerLog({
    required String dateKey,
    required PrayerName prayerName,
    required PrayerType type,

    /// Fard/Nawafil only; absent for Qaza logs.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    PrayerStatus? status,

    /// Qaza only: how many make-ups this log counts (0..50, D-075/07 §2
    /// `validLog`). `0` for Fard/Nawafil logs.
    @Default(0) int count,

    /// Fard only, optional "prayed with Jama'at" flag — not yet shown in the
    /// UI, reserved for future stats (09 §3.2).
    bool? inJamaat,

    /// uid of whoever wrote this log: the subject themself, a guardian or a
    /// teacher (07 `validLog` requires `markedBy == auth.uid`).
    required String markedBy,
    // `unknownEnumValue` needs a nullable field, and `source` is always
    // written by this same client version — safe to require for now.
    // Revisit once the app has real users and old-version compatibility
    // matters (03 §4).
    required PrayerLogSource source,
    required DateTime markedAt,

    /// Kept for compatibility with the current app's "UTC of window start"
    /// queries; [dateKey] is the source of truth for new code (09 §2).
    required DateTime dateTime,
  }) = _PrayerLog;

  factory PrayerLog.fromJson(Map<String, dynamic> json) =>
      _$PrayerLogFromJson(json);

  /// The deterministic document id for this log (`{dateKey}_{prayer}_{type}`).
  String get id => prayerLogId(dateKey, prayerName, type);

  /// Whether this log represents the prayer as prayed (Fard/Nawafil) or at
  /// least one make-up logged (Qaza).
  bool get isDone => type == PrayerType.qaza ? count > 0 : status == PrayerStatus.completed;
}
