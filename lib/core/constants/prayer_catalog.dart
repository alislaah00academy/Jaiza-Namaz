import '../../data/models/prayer_log.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_labels.dart';

/// Fard prayers shown on the main tracking screen (informational windows are
/// approximate). Text comes from ARB: `def.label(l10n)`.
class FardPrayerDef {
  const FardPrayerDef(this.name);

  final PrayerName name;

  String label(L10n l) => name.label(l);

  String startHint(L10n l) => switch (name) {
    PrayerName.fajr => l.fardFajrStartHint,
    PrayerName.zuhr => l.fardZuhrStartHint,
    PrayerName.asr => l.fardAsrStartHint,
    PrayerName.maghrib => l.fardMaghribStartHint,
    _ => l.fardIshaStartHint,
  };

  String endHint(L10n l) => switch (name) {
    PrayerName.fajr => l.fardFajrEndHint,
    PrayerName.zuhr => l.fardZuhrEndHint,
    PrayerName.asr => l.fardAsrEndHint,
    PrayerName.maghrib => l.fardMaghribEndHint,
    _ => l.fardIshaEndHint,
  };
}

const List<FardPrayerDef> kFardPrayerDefs = [
  FardPrayerDef(PrayerName.fajr),
  FardPrayerDef(PrayerName.zuhr),
  FardPrayerDef(PrayerName.asr),
  FardPrayerDef(PrayerName.maghrib),
  FardPrayerDef(PrayerName.isha),
  // Witr was removed from individual tracking — the app tracks the five
  // obligatory (Fard) prayers only. `PrayerName.witr` is kept in the enum so
  // any historical Firestore records still parse, but it's no longer shown
  // or markable anywhere.
];

/// Optional nawafil the user may track when enabled.
class NawafilDef {
  const NawafilDef(this.name);

  final PrayerName name;

  String label(L10n l) => name.label(l);
}

const List<NawafilDef> kNawafilDefs = [
  NawafilDef(PrayerName.tahajjud),
  NawafilDef(PrayerName.ishraq),
  NawafilDef(PrayerName.chasht),
  NawafilDef(PrayerName.awwabin),
  NawafilDef(PrayerName.rawatib),
  NawafilDef(PrayerName.taraweeh),
];
