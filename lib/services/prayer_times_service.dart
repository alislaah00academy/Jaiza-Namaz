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

@immutable
class PrayerWindow {
  const PrayerWindow({
    required this.key,
    required this.label,
    required this.start,
    required this.end,
  });

  final String key;
  final String label;
  final DateTime start;
  final DateTime end;
}

@immutable
class PrayerWindowStatus {
  const PrayerWindowStatus({
    required this.message,
    required this.nextKey,
    required this.nextLabel,
    required this.nextTime,
    required this.targetTime,
    required this.activePrayerKey,
  });

  final String message;
  final String nextKey;
  final String nextLabel;
  final DateTime nextTime;
  final DateTime targetTime;
  final String? activePrayerKey;
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
      PrayerWindow(
        key: PrayerName.fajr.name,
        label: 'Fajr',
        start: fajr,
        end: sunrise,
      ),
      PrayerWindow(
        key: PrayerName.zuhr.name,
        label: 'Zuhr',
        start: zuhr,
        end: asr,
      ),
      PrayerWindow(
        key: PrayerName.asr.name,
        label: 'Asr',
        start: asr,
        end: maghrib,
      ),
      PrayerWindow(
        key: PrayerName.maghrib.name,
        label: 'Maghrib',
        start: maghrib,
        end: isha,
      ),
      PrayerWindow(
        key: PrayerName.isha.name,
        label: 'Isha',
        start: isha,
        end: nextFajr,
      ),
    ];
  }

  List<PrayerWindow> get nawafilWindows {
    return [
      PrayerWindow(
        key: 'ashraq',
        label: 'Ashraq',
        start: sunrise.add(const Duration(minutes: 20)),
        end: zuhr,
      ),
      PrayerWindow(
        key: 'chasht',
        label: 'Chasht',
        start: sunrise.add(const Duration(hours: 1)),
        end: zuhr.subtract(const Duration(minutes: 10)),
      ),
      PrayerWindow(
        key: 'awwabin',
        label: 'Awwabin',
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
    final todayWindows = today.fardWindows;
    for (final window in todayWindows) {
      if (!now.isBefore(window.start) && now.isBefore(window.end)) {
        return PrayerWindowStatus(
          message:
              '${window.label} ends in ${compactDuration(window.end.difference(now))}',
          nextKey: _nextKeyAfter(window.key),
          nextLabel: _nextLabelAfter(window.key),
          nextTime: window.end,
          targetTime: window.end,
          activePrayerKey: window.key,
        );
      }
      if (now.isBefore(window.start)) {
        final previous = _previousWindow(todayWindows, window.key);
        final prefix = previous == null
            ? 'Next'
            : '${previous.label} time has ended – Next prayer';
        return PrayerWindowStatus(
          message:
              '$prefix: ${window.label} in ${compactDuration(window.start.difference(now))}',
          nextKey: window.key,
          nextLabel: window.label,
          nextTime: window.start,
          targetTime: window.start,
          activePrayerKey: null,
        );
      }
    }

    final nextFajr = tomorrow.fajr;
    return PrayerWindowStatus(
      message: 'Next: Fajr in ${compactDuration(nextFajr.difference(now))}',
      nextKey: PrayerName.fajr.name,
      nextLabel: 'Fajr',
      nextTime: nextFajr,
      targetTime: nextFajr,
      activePrayerKey: null,
    );
  }

  static String compactDuration(Duration duration) {
    final d = duration.isNegative ? Duration.zero : duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours <= 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  static PrayerWindow? _previousWindow(List<PrayerWindow> windows, String key) {
    final index = windows.indexWhere((w) => w.key == key);
    if (index <= 0) return null;
    return windows[index - 1];
  }

  static String _nextKeyAfter(String key) {
    return switch (key) {
      'fajr' => 'zuhr',
      'zuhr' => 'asr',
      'asr' => 'maghrib',
      'maghrib' => 'isha',
      _ => 'fajr',
    };
  }

  static String _nextLabelAfter(String key) {
    return switch (key) {
      'fajr' => 'Zuhr',
      'zuhr' => 'Asr',
      'asr' => 'Maghrib',
      'maghrib' => 'Isha',
      _ => 'Fajr',
    };
  }
}
