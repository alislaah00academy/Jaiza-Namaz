import '../enums/prayer_enums.dart';

/// Deterministic prayer log id `{dateKey}_{prayerName}_{type}` (06 §2.2), e.g.
/// `2026-09-28_asr_fard`. One doc per subject/day/prayer/type, so marking is an
/// idempotent `set()` that is safe offline.
String prayerLogId(String dateKey, PrayerName prayer, PrayerType type) =>
    '${dateKey}_${prayer.name}_${type.name}';
