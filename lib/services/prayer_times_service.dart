import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/foundation.dart';

import '../data/models/prayer_log.dart';
import '../features/settings/data/prayer_settings.dart';

const List<PrayerName> kWidgetFardPrayers = [
  PrayerName.fajr,
  PrayerName.zuhr,
  PrayerName.asr,
  PrayerName.maghrib,
  PrayerName.isha,
];

/// One prayer's time window. Show its name with `prayer.label(l10n)`.
@immutable
class PrayerWindow {
  const PrayerWindow({
    required this.prayer,
    required this.start,
    required this.end,
  });

  final PrayerName prayer;
  final DateTime start;
  final DateTime end;

  /// `prayer.name`, e.g. `'asr'`.
  String get key => prayer.name;
}

/// Where "now" sits among today's Fard windows. Pure data — the UI words it
/// from ARB (16 §1).
@immutable
class PrayerWindowStatus {
  const PrayerWindowStatus({
    required this.nextPrayer,
    required this.nextTime,
    required this.targetTime,
    required this.activePrayer,
  });

  /// The prayer after the current one, or the next one to start.
  final PrayerName nextPrayer;
  final DateTime nextTime;

  /// When the countdown ends: the active window's end, else the next start.
  final DateTime targetTime;

  /// The Fard prayer whose window is open now, if any.
  final PrayerName? activePrayer;

  String get nextKey => nextPrayer.name;
  String? get activePrayerKey => activePrayer?.name;
}

/// One calendar day's computed times (local wall clock).
@immutable
class DailyPrayerSchedule {
  const DailyPrayerSchedule({
    required this.dateKey,
    required this.fajr,
    required this.sunrise,
    required this.zuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextFajr,
  });

  final String dateKey;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime zuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Next day's Fajr (used as Isha window end).
  final DateTime nextFajr;

  /// End of the "time window" for each Fard prayer (notification fires here).
  DateTime endTimeFor(PrayerName name) {
    return switch (name) {
      PrayerName.fajr => sunrise,
      PrayerName.zuhr => asr,
      PrayerName.asr => maghrib,
      PrayerName.maghrib => isha,
      PrayerName.isha => nextFajr,
      _ => isha,
    };
  }

  DateTime startTimeFor(PrayerName name) {
    return switch (name) {
      PrayerName.fajr => fajr,
      PrayerName.zuhr => zuhr,
      PrayerName.asr => asr,
      PrayerName.maghrib => maghrib,
      PrayerName.isha => isha,
      _ => isha,
    };
  }

  List<PrayerWindow> get fardWindows {
    return [
      PrayerWindow(prayer: PrayerName.fajr, start: fajr, end: sunrise),
      PrayerWindow(prayer: PrayerName.zuhr, start: zuhr, end: asr),
      PrayerWindow(prayer: PrayerName.asr, start: asr, end: maghrib),
      PrayerWindow(prayer: PrayerName.maghrib, start: maghrib, end: isha),
      PrayerWindow(prayer: PrayerName.isha, start: isha, end: nextFajr),
    ];
  }

  List<PrayerWindow> get nawafilWindows {
    return [
      PrayerWindow(
        prayer: PrayerName.ishraq,
        start: sunrise.add(const Duration(minutes: 20)),
        end: zuhr,
      ),
      PrayerWindow(
        prayer: PrayerName.chasht,
        start: sunrise.add(const Duration(hours: 1)),
        end: zuhr.subtract(const Duration(minutes: 10)),
      ),
      PrayerWindow(
        prayer: PrayerName.awwabin,
        start: maghrib.add(const Duration(minutes: 5)),
        end: isha,
      ),
    ];
  }
}

/// Wraps `adhan_dart` with app settings.
abstract final class PrayerTimesService {
  static adhan.CalculationParameters _params(PrayerSettingsParsed s) {
    adhan.CalculationParameters base;
    switch (s.calcMethod) {
      case 'muslimWorldLeague':
        base = adhan.CalculationMethodParameters.muslimWorldLeague();
        break;
      case 'ummAlQura':
        base = adhan.CalculationMethodParameters.ummAlQura();
        break;
      case 'northAmerica':
        base = adhan.CalculationMethodParameters.northAmerica();
        break;
      case 'egyptian':
        base = adhan.CalculationMethodParameters.egyptian();
        break;
      case 'tehran':
        base = adhan.CalculationMethodParameters.tehran();
        break;
      case 'singapore':
        base = adhan.CalculationMethodParameters.singapore();
        break;
      case 'karachi':
      default:
        base = adhan.CalculationMethodParameters.karachi();
    }
    base.madhab = s.madhab == 'shafi'
        ? adhan.Madhab.shafi
        : adhan.Madhab.hanafi;
    return base;
  }

  static DailyPrayerSchedule forLocalDay({
    required DateTime localDay,
    required double latitude,
    required double longitude,
    required PrayerSettingsParsed settings,
  }) {
    final y = localDay.year;
    final m = localDay.month;
    final d = localDay.day;
    final date = DateTime(y, m, d);
    final coords = adhan.Coordinates(latitude, longitude);
    final pt = adhan.PrayerTimes(
      date: date,
      coordinates: coords,
      calculationParameters: _params(settings),
      precision: true,
    );

    final dk =
        '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

    return DailyPrayerSchedule(
      dateKey: dk,
      fajr: pt.fajr.toLocal(),
      sunrise: pt.sunrise.toLocal(),
      zuhr: pt.dhuhr.toLocal(),
      asr: pt.asr.toLocal(),
      maghrib: pt.maghrib.toLocal(),
      isha: pt.isha.toLocal(),
      nextFajr: pt.fajrAfter.toLocal(),
    );
  }

  /// Next Fard prayer **start** after [now], and its start time.
  /// Today + next two local calendar days (for notifications + widgets).
  static List<DailyPrayerSchedule> threeDaySchedules({
    required double latitude,
    required double longitude,
    required PrayerSettingsParsed settings,
  }) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 0; i < 3; i++)
        forLocalDay(
          localDay: base.add(Duration(days: i)),
          latitude: latitude,
          longitude: longitude,
          settings: settings,
        ),
    ];
  }

  static (PrayerName, DateTime) nextFardPrayerStart({
    required DateTime now,
    required DailyPrayerSchedule today,
    required DailyPrayerSchedule tomorrow,
  }) {
    final ordered = <(PrayerName, DateTime)>[
      (PrayerName.fajr, today.fajr),
      (PrayerName.zuhr, today.zuhr),
      (PrayerName.asr, today.asr),
      (PrayerName.maghrib, today.maghrib),
      (PrayerName.isha, today.isha),
    ];
    for (final e in ordered) {
      if (now.isBefore(e.$2)) return e;
    }
    return (PrayerName.fajr, tomorrow.fajr);
  }

  static PrayerWindowStatus currentWindowStatus({
    required DateTime now,
    required DailyPrayerSchedule today,
    required DailyPrayerSchedule tomorrow,
  }) {
    for (final window in today.fardWindows) {
      if (!now.isBefore(window.start) && now.isBefore(window.end)) {
        return PrayerWindowStatus(
          nextPrayer: _nextAfter(window.prayer),
          nextTime: window.end,
          targetTime: window.end,
          activePrayer: window.prayer,
        );
      }
      if (now.isBefore(window.start)) {
        return PrayerWindowStatus(
          nextPrayer: window.prayer,
          nextTime: window.start,
          targetTime: window.start,
          activePrayer: null,
        );
      }
    }

    final nextFajr = tomorrow.fajr;
    return PrayerWindowStatus(
      nextPrayer: PrayerName.fajr,
      nextTime: nextFajr,
      targetTime: nextFajr,
      activePrayer: null,
    );
  }

  static PrayerName _nextAfter(PrayerName p) => switch (p) {
    PrayerName.fajr => PrayerName.zuhr,
    PrayerName.zuhr => PrayerName.asr,
    PrayerName.asr => PrayerName.maghrib,
    PrayerName.maghrib => PrayerName.isha,
    _ => PrayerName.fajr,
  };
}
