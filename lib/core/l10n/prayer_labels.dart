import 'package:jaiza_core/jaiza_core.dart';

import 'l10n.dart';

/// Prayer names always come from ARB, never from `enum.name` (16 §1.1).
extension PrayerNameL10n on PrayerName {
  String label(L10n l) => switch (this) {
    PrayerName.fajr => l.prayerFajr,
    PrayerName.zuhr => l.prayerZuhr,
    PrayerName.asr => l.prayerAsr,
    PrayerName.maghrib => l.prayerMaghrib,
    PrayerName.isha => l.prayerIsha,
    PrayerName.witr => l.prayerWitr,
    PrayerName.tahajjud => l.prayerTahajjud,
    PrayerName.ishraq => l.prayerIshraq,
    PrayerName.chasht => l.prayerChasht,
    PrayerName.awwabin => l.prayerAwwabin,
    PrayerName.rawatib => l.prayerRawatib,
    PrayerName.taraweeh => l.prayerTaraweeh,
    PrayerName.qazaGeneric => l.prayerQazaGeneric,
  };
}
