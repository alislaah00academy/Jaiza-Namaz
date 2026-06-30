import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/jaiza_dates.dart';
import '../../data/models/prayer_log.dart';
import '../../features/settings/data/prayer_settings.dart';
import '../../providers/providers.dart';
import '../../services/location_service.dart';
import '../../services/notifications_service.dart';
import '../../services/prayer_times_service.dart';
import '../constants/jaiza_strip_prayers.dart';

/// Deep-link host/path used by native widgets (must match Kotlin / Swift).
abstract final class JaizaWidgetUri {
  static const scheme = 'jaiza';
  static const host = 'prayer';
  static const pathMark = '/mark';
}

/// Bridges SharedPreferences / App Group data for home-screen widgets + parses taps.
abstract final class HomeWidgetBridge {
  static StreamSubscription<Uri?>? _clickSub;

  /// iOS App Group used by `home_widget` (must match Xcode capability).
  static const iosAppGroupId = 'group.com.alislaacademy.jayzanamaz.jaizaNamaz';

  /// SharedPreferences keys written by Flutter.
  static const payloadKey = 'jaiza_widget_payload';
  static const uidKey = 'jaiza_uid';

  /// Qualified Android `AppWidgetProvider` class name (must match manifest).
  static const qualifiedAndroidWidget =
      'com.alislaacademy.jayzanamaz.jaiza_namaz.widget.JaizaPrayerWidget';

  /// Widget kind name on iOS (Swift `struct …: Widget`).
  static const iosWidgetName = 'JaizaPrayerWidget';

  /// Prayer times widget (Widget B) payload.
  static const payloadKeyB = 'jaiza_widget_b_payload';
  static const prayerSettingsCacheKey = 'jaiza_prayer_settings_json';

  static const qualifiedAndroidWidgetTimes =
      'com.alislaacademy.jayzanamaz.jaiza_namaz.widget.JaizaPrayerTimesWidget';
  static const iosWidgetNameTimes = 'JaizaPrayerTimesWidget';

  /// All-in-one glass widget payload.
  static const payloadKeyUnified = 'jaiza_unified_widget_payload';
  static const qualifiedAndroidWidgetUnified =
      'com.alislaacademy.jayzanamaz.jaiza_namaz.widget.JaizaUnifiedPrayerWidget';
  static const iosWidgetNameUnified = 'JaizaUnifiedPrayerWidget';

  static Future<void> bootstrap(WidgetRef ref) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(iosAppGroupId);
    }

    await _clickSub?.cancel();
    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    await handleLaunchUri(ref, initial);

    _clickSub = HomeWidget.widgetClicked.listen((uri) {
      handleLaunchUri(ref, uri);
    });

    await syncAllWidgets(ref);
  }

  static Future<void> dispose() async {
    await _clickSub?.cancel();
    _clickSub = null;
  }

  /// Saves today's strip state + pushes to native widgets.
  static Future<void> syncWidget(WidgetRef ref) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null || uid.isEmpty) {
      await HomeWidget.saveWidgetData(uidKey, '');
      return;
    }

    final map = ref.read(todayFardMapProvider).valueOrNull ?? {};
    final user = ref.read(appUserStreamProvider).valueOrNull;
    final greeting = user?.name.isNotEmpty == true
        ? 'Assalamu — ${user!.name}'
        : 'Assalamu alaikum';

    final prayers = <String, String>{};
    for (final name in kJaizaStripPrayerNames) {
      final log = map[name];
      prayers[name.name] = log == null
          ? ''
          : (log.status == PrayerStatus.completed ? 'completed' : 'missed');
    }

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final payload = jsonEncode({
      'title': 'Jaiza · Today\'s Prayers',
      'greeting': greeting,
      'today': {
        'dateKey': jaizaWidgetDateKey(now),
        'dateLine': formatGregHijriLine(now),
      },
      'tomorrow': {
        'dateKey': jaizaWidgetDateKey(tomorrow),
        'dateLine': formatGregHijriLine(tomorrow),
      },
      'prayers': prayers,
    });

    await HomeWidget.saveWidgetData(uidKey, uid);
    await HomeWidget.saveWidgetData(payloadKey, payload);
    await HomeWidget.updateWidget(
      qualifiedAndroidName: qualifiedAndroidWidget,
      iOSName: iosWidgetName,
    );
  }

  /// Prayer times + next countdown (Widget B) + reschedule end notifications.
  static Future<void> syncWidgetB(WidgetRef ref) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null || uid.isEmpty) {
      await HomeWidget.saveWidgetData(payloadKeyB, '{}');
      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidWidgetTimes,
        iOSName: iosWidgetNameTimes,
      );
      return;
    }

    try {
      final user = ref.read(appUserStreamProvider).valueOrNull;
      final settings =
          user?.prayerSettingsParsed ?? PrayerSettingsParsed.defaults();

      await HomeWidget.saveWidgetData(
        prayerSettingsCacheKey,
        jsonEncode(settings.toFirestoreMap()),
      );

      double lat;
      double lon;
      String label;
      if (settings.useGps) {
        final pos = await LocationService.getCurrentPosition();
        if (pos != null) {
          lat = pos.lat;
          lon = pos.lon;
          label = pos.label ?? settings.manualLabel;
        } else {
          final cached = await LocationService.readCachedCoords();
          lat = cached?.lat ?? settings.manualLat;
          lon = cached?.lon ?? settings.manualLon;
          label = cached?.label ?? settings.manualLabel;
        }
      } else {
        lat = settings.manualLat;
        lon = settings.manualLon;
        label = settings.manualLabel;
      }

      final days = PrayerTimesService.threeDaySchedules(
        latitude: lat,
        longitude: lon,
        settings: settings,
      );
      final today = days[0];
      final tomorrow = days[1];
      final now = DateTime.now();
      final fardMap = ref.read(todayFardMapProvider).valueOrNull ?? {};
      final next = PrayerTimesService.nextFardPrayerStart(
        now: now,
        today: today,
        tomorrow: tomorrow,
      );

      String fmt(DateTime t) => DateFormat('HH:mm').format(t.toLocal());

      final payload = jsonEncode({
        'title': 'Jaiza · Prayer times',
        'subtitle':
            '${PrayerSettingsParsed.calcMethodLabel(settings.calcMethod)} · ${settings.madhab == 'hanafi' ? 'Hanafi' : 'Shafi’i'} · $label',
        'dateKey': today.dateKey,
        'times': {
          'fajr': fmt(today.fajr),
          'zuhr': fmt(today.zuhr),
          'asr': fmt(today.asr),
          'maghrib': fmt(today.maghrib),
          'isha': fmt(today.isha),
        },
        'prayers': {
          for (final name in kJaizaStripPrayerNames)
            name.name: fardMap[name]?.status.firestoreValue ?? '',
        },
        'startsEpochMs': {
          'fajr': today.fajr.millisecondsSinceEpoch,
          'zuhr': today.zuhr.millisecondsSinceEpoch,
          'asr': today.asr.millisecondsSinceEpoch,
          'maghrib': today.maghrib.millisecondsSinceEpoch,
          'isha': today.isha.millisecondsSinceEpoch,
        },
        'tomorrowFajrEpochMs': tomorrow.fajr.millisecondsSinceEpoch,
        'nextPrayer': next.$1.name,
        'nextStartEpochMs': next.$2.millisecondsSinceEpoch,
        'sunriseEpochMs': today.sunrise.millisecondsSinceEpoch,
      });

      await HomeWidget.saveWidgetData(payloadKeyB, payload);
      await NotificationsService.rescheduleWithContext(
        settings: settings,
        schedules: days,
        completedByDate: _completedByDate(today.dateKey, ref),
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidWidgetTimes,
        iOSName: iosWidgetNameTimes,
      );
    } catch (_) {
      /* keep widget resilient */
    }
  }

  static Future<void> syncUnifiedWidget(WidgetRef ref) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null || uid.isEmpty) {
      await HomeWidget.saveWidgetData(payloadKeyUnified, '{}');
      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidWidgetUnified,
        iOSName: iosWidgetNameUnified,
      );
      return;
    }

    try {
      final user = ref.read(appUserStreamProvider).valueOrNull;
      final settings =
          user?.prayerSettingsParsed ?? PrayerSettingsParsed.defaults();
      final loc = await _resolveLocation(settings);
      final days = PrayerTimesService.threeDaySchedules(
        latitude: loc.$1,
        longitude: loc.$2,
        settings: settings,
      );
      final today = days[0];
      final tomorrow = days[1];
      final now = DateTime.now();
      final status = PrayerTimesService.currentWindowStatus(
        now: now,
        today: today,
        tomorrow: tomorrow,
      );
      final fardMap = ref.read(todayFardMapProvider).valueOrNull ?? {};

      String fmt(DateTime t) => DateFormat('hh:mm a').format(t.toLocal());
      String range(PrayerWindow w) => '${fmt(w.start)} – ${fmt(w.end)}';

      final firstName = (user?.name.trim().split(RegExp(r'\s+')).first ?? '')
          .trim();
      final payload = jsonEncode({
        'title': 'Jaiza · Today’s Prayers',
        'firstName': firstName,
        'dateLine': formatGregHijriLine(now),
        'location': loc.$3,
        'statusLine': status.message,
        'activePrayer': status.activePrayerKey ?? '',
        'targetEpochMs': status.targetTime.millisecondsSinceEpoch,
        'nextPrayer': status.nextKey,
        'nextPrayerLabel': status.nextLabel,
        'nextStartEpochMs': status.nextTime.millisecondsSinceEpoch,
        'fard': [
          for (final window in today.fardWindows)
            {
              'key': window.key,
              'label': window.label,
              'time': fmt(window.start),
              'startEpochMs': window.start.millisecondsSinceEpoch,
              'endEpochMs': window.end.millisecondsSinceEpoch,
              'status':
                  fardMap[PrayerNameX.fromFirestore(window.key)]
                      ?.status
                      .firestoreValue ??
                  '',
            },
        ],
        'nawafil': [
          for (final window in today.nawafilWindows)
            {
              'key': window.key,
              'label': window.label,
              'range': range(window),
              'startEpochMs': window.start.millisecondsSinceEpoch,
              'endEpochMs': window.end.millisecondsSinceEpoch,
            },
        ],
      });

      await HomeWidget.saveWidgetData(payloadKeyUnified, payload);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidWidgetUnified,
        iOSName: iosWidgetNameUnified,
      );
    } catch (_) {
      /* keep widget resilient */
    }
  }

  static Future<void> syncAllWidgets(WidgetRef ref) async {
    await syncWidget(ref);
    await syncWidgetB(ref);
    await syncUnifiedWidget(ref);
  }

  static Map<String, Set<PrayerName>> _completedByDate(
    String dateKey,
    WidgetRef ref,
  ) {
    final map = ref.read(todayFardMapProvider).valueOrNull ?? {};
    return {
      dateKey: {
        for (final e in map.entries)
          if (e.value.status == PrayerStatus.completed) e.key,
      },
    };
  }

  static Future<(double, double, String)> _resolveLocation(
    PrayerSettingsParsed settings,
  ) async {
    if (settings.useGps) {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        return (pos.lat, pos.lon, pos.label ?? settings.manualLabel);
      }
      final cached = await LocationService.readCachedCoords();
      if (cached != null) {
        return (cached.lat, cached.lon, cached.label);
      }
    }
    return (settings.manualLat, settings.manualLon, settings.manualLabel);
  }

  /// Handles `jaiza://prayer/mark?name=fajr&status=completed|missed`.
  static Future<void> handleLaunchUri(WidgetRef ref, Uri? uri) async {
    if (uri == null || uri.scheme != JaizaWidgetUri.scheme) return;
    if (uri.host != JaizaWidgetUri.host ||
        uri.path != JaizaWidgetUri.pathMark) {
      return;
    }

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null || uid.isEmpty) return;

    final rawName = uri.queryParameters['name'];
    final rawStatus = uri.queryParameters['status'];
    if (rawName == null || rawStatus == null) return;

    final prayer = PrayerNameX.fromFirestore(rawName);
    if (prayer == null || !kJaizaStripPrayerNames.contains(prayer)) return;

    final status = switch (rawStatus) {
      'completed' => PrayerStatus.completed,
      'missed' => PrayerStatus.missed,
      _ => null,
    };
    if (status == null) return;

    try {
      await ref
          .read(prayerRepositoryProvider)
          .upsertPrayer(
            userId: uid,
            prayerName: prayer,
            type: PrayerType.fard,
            status: status,
          );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await syncAllWidgets(ref);
    } catch (_) {
      /* ignore — widget tap should not crash app */
    }
  }
}

/// Used by Android background isolate callback (widget tap without opening app).
abstract final class BackgroundWidgetWriter {
  static PrayerName? _parsePrayer(String rawName) {
    final prayer = PrayerNameX.fromFirestore(rawName);
    if (prayer == null || !kJaizaStripPrayerNames.contains(prayer)) return null;
    return prayer;
  }

  static PrayerStatus? _parseStatus(String rawStatus) {
    return switch (rawStatus) {
      'completed' => PrayerStatus.completed,
      'missed' => PrayerStatus.missed,
      _ => null,
    };
  }

  static Future<void> applyOptimistic({
    required String uid,
    required String name,
    required String status,
  }) async {
    final prayer = _parsePrayer(name);
    final parsedStatus = _parseStatus(status);
    if (uid.isEmpty || prayer == null || parsedStatus == null) return;

    final payloadRaw = await HomeWidget.getWidgetData<String>(
      HomeWidgetBridge.payloadKey,
      defaultValue: '{}',
    );

    Map<String, dynamic> root;
    try {
      root = jsonDecode(payloadRaw ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      root = <String, dynamic>{};
    }

    final now = DateTime.now();
    final todayKey = jaizaWidgetDateKey(now);
    final tomorrow = now.add(const Duration(days: 1));

    final today = Map<String, dynamic>.from(root['today'] as Map? ?? const {});
    final tomorrowMap = Map<String, dynamic>.from(
      root['tomorrow'] as Map? ?? const {},
    );
    final prayers = Map<String, dynamic>.from(
      root['prayers'] as Map? ?? const <String, dynamic>{},
    );

    final rootTodayKey = today['dateKey'] as String?;
    if (rootTodayKey != todayKey) {
      prayers
        ..clear()
        ..addEntries(kJaizaStripPrayerNames.map((p) => MapEntry(p.name, '')));
      today
        ..clear()
        ..addAll({'dateKey': todayKey, 'dateLine': formatGregHijriLine(now)});
      tomorrowMap
        ..clear()
        ..addAll({
          'dateKey': jaizaWidgetDateKey(tomorrow),
          'dateLine': formatGregHijriLine(tomorrow),
        });
    }

    prayers[prayer.name] = parsedStatus.firestoreValue;

    final updated = <String, dynamic>{
      ...root,
      'today': today,
      'tomorrow': tomorrowMap,
      'prayers': prayers,
    };

    await HomeWidget.saveWidgetData(HomeWidgetBridge.uidKey, uid);
    await HomeWidget.saveWidgetData(
      HomeWidgetBridge.payloadKey,
      jsonEncode(updated),
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: HomeWidgetBridge.qualifiedAndroidWidget,
      iOSName: HomeWidgetBridge.iosWidgetName,
    );

    await _applyStatusToTimesPayload(prayer, parsedStatus);
    await _applyStatusToUnifiedPayload(prayer, parsedStatus);
  }

  static Future<void> _applyStatusToTimesPayload(
    PrayerName prayer,
    PrayerStatus status,
  ) async {
    final raw = await HomeWidget.getWidgetData<String>(
      HomeWidgetBridge.payloadKeyB,
      defaultValue: '{}',
    );
    final root = _decodeMap(raw);
    final prayers = Map<String, dynamic>.from(
      root['prayers'] as Map? ?? const <String, dynamic>{},
    );
    prayers[prayer.name] = status.firestoreValue;
    root['prayers'] = prayers;
    await HomeWidget.saveWidgetData(
      HomeWidgetBridge.payloadKeyB,
      jsonEncode(root),
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: HomeWidgetBridge.qualifiedAndroidWidgetTimes,
      iOSName: HomeWidgetBridge.iosWidgetNameTimes,
    );
  }

  static Future<void> _applyStatusToUnifiedPayload(
    PrayerName prayer,
    PrayerStatus status,
  ) async {
    final raw = await HomeWidget.getWidgetData<String>(
      HomeWidgetBridge.payloadKeyUnified,
      defaultValue: '{}',
    );
    final root = _decodeMap(raw);
    final rows = List<dynamic>.from(root['fard'] as List? ?? const []);
    root['fard'] = [
      for (final row in rows)
        if (row is Map)
          {
            ...Map<String, dynamic>.from(row),
            if (row['key'] == prayer.name) 'status': status.firestoreValue,
          }
        else
          row,
    ];
    await HomeWidget.saveWidgetData(
      HomeWidgetBridge.payloadKeyUnified,
      jsonEncode(root),
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: HomeWidgetBridge.qualifiedAndroidWidgetUnified,
      iOSName: HomeWidgetBridge.iosWidgetNameUnified,
    );
  }

  static Map<String, dynamic> _decodeMap(String? raw) {
    try {
      return Map<String, dynamic>.from(
        jsonDecode(raw ?? '{}') as Map? ?? const <String, dynamic>{},
      );
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<void> persist({
    required String uid,
    required String name,
    required String status,
  }) async {
    final prayer = _parsePrayer(name);
    final parsedStatus = _parseStatus(status);
    if (uid.isEmpty || prayer == null || parsedStatus == null) return;

    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null || authUid != uid) {
      return;
    }

    final now = DateTime.now();
    final id = PrayerLog.deterministicId(
      userId: uid,
      localDateKey: AppDateUtils.localDateKey(now),
      prayerName: prayer,
      type: PrayerType.fard,
    );

    final log = PrayerLog(
      id: id,
      userId: uid,
      prayerName: prayer,
      type: PrayerType.fard,
      status: parsedStatus,
      dateTime: now,
    );

    await FirebaseFirestore.instance
        .collection('prayers')
        .doc(id)
        .set(log.toFirestore(), SetOptions(merge: true));
  }
}
