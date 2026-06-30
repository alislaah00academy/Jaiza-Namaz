import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/prayer_log.dart';
import '../features/settings/data/prayer_settings.dart';
import 'prayer_times_service.dart';

/// Local notifications at end of each Fard prayer window.
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _androidChannelId = 'jaiza_prayer_end';
  static const _androidChannelName = 'Prayer time reminders';

  /// Legacy deterministic id kept so previously scheduled end notifications
  /// can be cancelled when users update to the new reminder rules.
  static int notificationIdFor(String dateKey, PrayerName prayer) {
    final p = dateKey.split('-');
    final y = int.parse(p[0]);
    final m = int.parse(p[1]);
    final d = int.parse(p[2]);
    final day = DateTime.utc(y, m, d);
    final days = day.difference(DateTime.utc(1970, 1, 1)).inDays;
    return days * 10 + _prayerIndex(prayer);
  }

  static int startNotificationIdFor(String dateKey, PrayerName prayer) {
    return _notificationIdFor(dateKey, prayer, 1);
  }

  static int endReminderIdFor(String dateKey, PrayerName prayer) {
    return _notificationIdFor(dateKey, prayer, 2);
  }

  /// Deterministic 32-bit safe id: daysSinceEpoch * 100 + type + prayer index.
  static int _notificationIdFor(String dateKey, PrayerName prayer, int type) {
    final p = dateKey.split('-');
    final y = int.parse(p[0]);
    final m = int.parse(p[1]);
    final d = int.parse(p[2]);
    final day = DateTime.utc(y, m, d);
    final days = day.difference(DateTime.utc(1970, 1, 1)).inDays;
    return days * 100 + (type * 10) + _prayerIndex(prayer);
  }

  static int _prayerIndex(PrayerName prayer) {
    return switch (prayer) {
      PrayerName.fajr => 0,
      PrayerName.zuhr => 1,
      PrayerName.asr => 2,
      PrayerName.maghrib => 3,
      PrayerName.isha => 4,
      _ => 9,
    };
  }

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: 'Reminders when a prayer time window ends',
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final s = await Permission.notification.status;
      if (s.isGranted) return true;
      final r = await Permission.notification.request();
      return r.isGranted;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final r = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return r ?? false;
    }
    return false;
  }

  Future<void> cancelForPrayer(DateTime dayContext, PrayerName prayer) async {
    if (!_initialized) await init();
    if (kIsWeb) return;
    final key =
        '${dayContext.year.toString().padLeft(4, '0')}-${dayContext.month.toString().padLeft(2, '0')}-${dayContext.day.toString().padLeft(2, '0')}';
    await _plugin.cancel(endReminderIdFor(key, prayer));
    await _plugin.cancel(notificationIdFor(key, prayer));
  }

  Future<void> cancelKnownRange({
    required List<String> dateKeys,
    required List<PrayerName> prayers,
  }) async {
    if (!_initialized) await init();
    if (kIsWeb) return;
    for (final dk in dateKeys) {
      for (final p in prayers) {
        await _plugin.cancel(notificationIdFor(dk, p));
        await _plugin.cancel(startNotificationIdFor(dk, p));
        await _plugin.cancel(endReminderIdFor(dk, p));
      }
    }
  }

  /// Schedules start notifications and 10-minute-before-end reminders.
  Future<void> rescheduleFromSchedules({
    required PrayerSettingsParsed settings,
    required List<DailyPrayerSchedule> schedules,
    Map<String, Set<PrayerName>> completedByDate = const {},
  }) async {
    if (!_initialized) await init();
    if (kIsWeb) return;
    if (!settings.notificationsEnabled) {
      await cancelKnownRange(
        dateKeys: schedules.map((e) => e.dateKey).toList(),
        prayers: const [
          PrayerName.fajr,
          PrayerName.zuhr,
          PrayerName.asr,
          PrayerName.maghrib,
          PrayerName.isha,
        ],
      );
      return;
    }

    final granted = await requestNotificationPermission();
    if (!granted) return;

    final now = DateTime.now();
    final keys = schedules.map((e) => e.dateKey).toList();
    await cancelKnownRange(
      dateKeys: keys,
      prayers: const [
        PrayerName.fajr,
        PrayerName.zuhr,
        PrayerName.asr,
        PrayerName.maghrib,
        PrayerName.isha,
      ],
    );

    for (final day in schedules) {
      for (final prayer in const [
        PrayerName.fajr,
        PrayerName.zuhr,
        PrayerName.asr,
        PrayerName.maghrib,
        PrayerName.isha,
      ]) {
        final start = day.startTimeFor(prayer);
        final endReminder = day
            .endTimeFor(prayer)
            .subtract(const Duration(minutes: 10));
        final isCompleted =
            completedByDate[day.dateKey]?.contains(prayer) ?? false;

        if (settings.startNotificationFor(prayer) && start.isAfter(now)) {
          await _plugin.zonedSchedule(
            startNotificationIdFor(day.dateKey, prayer),
            'Jaiza',
            '${_prettyPrayer(prayer)} time has begun. Don’t miss your prayer.',
            tz.TZDateTime.from(start, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannelId,
                _androidChannelName,
                channelDescription: 'Prayer start and reminder notifications',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }

        if (!settings.notificationFor(prayer)) continue;
        if (isCompleted || !endReminder.isAfter(now)) continue;

        await _plugin.zonedSchedule(
          endReminderIdFor(day.dateKey, prayer),
          'Jaiza',
          '${_prettyPrayer(prayer)} ends in 10 minutes. Have you prayed?',
          tz.TZDateTime.from(endReminder, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: 'Prayer start and reminder notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  /// Full reschedule for signed-in user using [schedules] (typically 3 days).
  static Future<void> rescheduleWithContext({
    required PrayerSettingsParsed settings,
    required List<DailyPrayerSchedule> schedules,
    Map<String, Set<PrayerName>> completedByDate = const {},
  }) => instance.rescheduleFromSchedules(
    settings: settings,
    schedules: schedules,
    completedByDate: completedByDate,
  );

  Future<void> scheduleTestIn(Duration delay) async {
    if (!_initialized) await init();
    if (kIsWeb) return;
    final granted = await requestNotificationPermission();
    if (!granted) return;
    final when = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      999999,
      'Jaiza',
      'Test notification — prayer reminders are working.',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static String _prettyPrayer(PrayerName name) {
    return switch (name) {
      PrayerName.fajr => 'Fajr',
      PrayerName.zuhr => 'Zuhr',
      PrayerName.asr => 'Asr',
      PrayerName.maghrib => 'Maghrib',
      PrayerName.isha => 'Isha',
      _ => name.name,
    };
  }
}
