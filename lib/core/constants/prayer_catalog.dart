import '../../data/models/prayer_log.dart';

/// Fard prayers shown on the main tracking screen (informational windows are approximate).
class FardPrayerDef {
  const FardPrayerDef({
    required this.name,
    required this.label,
    required this.startHint,
    required this.endHint,
  });

  final PrayerName name;
  final String label;
  final String startHint;
  final String endHint;
}

const List<FardPrayerDef> kFardPrayerDefs = [
  FardPrayerDef(
    name: PrayerName.fajr,
    label: 'Fajr',
    startHint: 'Begins at dawn',
    endHint: 'Until sunrise',
  ),
  FardPrayerDef(
    name: PrayerName.zuhr,
    label: 'Zuhr',
    startHint: 'After zenith',
    endHint: 'Before Asr',
  ),
  FardPrayerDef(
    name: PrayerName.asr,
    label: 'Asr',
    startHint: 'Afternoon',
    endHint: 'Before sunset',
  ),
  FardPrayerDef(
    name: PrayerName.maghrib,
    label: 'Maghrib',
    startHint: 'Just after sunset',
    endHint: 'Until Isha',
  ),
  FardPrayerDef(
    name: PrayerName.isha,
    label: 'Isha',
    startHint: 'Night begins',
    endHint: 'Until Fajr',
  ),
  FardPrayerDef(
    name: PrayerName.witr,
    label: 'Witr',
    startHint: 'After Isha',
    endHint: 'Before Fajr',
  ),
];

/// Optional nawafil the user may track when enabled.
class NawafilDef {
  const NawafilDef({required this.name, required this.label});

  final PrayerName name;
  final String label;
}

const List<NawafilDef> kNawafilDefs = [
  NawafilDef(name: PrayerName.tahajjud, label: 'Tahajjud'),
  NawafilDef(name: PrayerName.ishraq, label: 'Ishraq'),
  NawafilDef(name: PrayerName.chasht, label: 'Chasht (Duha)'),
  NawafilDef(name: PrayerName.awwabin, label: 'Salat al-Awwabin'),
  NawafilDef(name: PrayerName.rawatib, label: 'Rawatib'),
  NawafilDef(name: PrayerName.taraweeh, label: 'Taraweeh'),
];
