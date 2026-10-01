/// Prayer enums shared by the app, the dashboard and (by value) Cloud Functions.
///
/// Values are stored in Firestore as their `name` (e.g. `'fajr'`), so **never
/// rename a value** — add a new one instead (03 §4). Models read them with
/// `@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)` so an old app
/// never crashes on a value added later.
library;

enum PrayerName {
  fajr,
  zuhr,
  asr,
  maghrib,
  isha,
  witr,
  tahajjud,
  ishraq,
  chasht,
  awwabin,
  rawatib,
  taraweeh,

  /// Legacy catch-all used by the current Qaza screens; new Qaza logs name
  /// the Fard prayer they make up (06 §2.2).
  qazaGeneric;

  /// The five daily obligatory prayers, in order.
  static const List<PrayerName> fard = [fajr, zuhr, asr, maghrib, isha];

  bool get isFard => fard.contains(this);

  /// Prayers that may still be prayed after midnight and before Fajr, and
  /// so belong to the **previous** prayer day (09 §2).
  bool get belongsToPreviousDayBeforeFajr =>
      this == isha || this == witr || this == tahajjud;
}

enum PrayerType { fard, nawafil, qaza }

enum PrayerStatus { completed, missed }

/// Who/what wrote a prayer log (06 §2.2 `source`).
enum PrayerLogSource { app, widget, teacher, guardian }
