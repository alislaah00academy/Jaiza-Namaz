import 'package:flutter/foundation.dart';

import '../../../data/models/prayer_log.dart';

/// Firestore key: `users/{uid}.prayerSettings` (map).
@immutable
class PrayerSettingsParsed {
  const PrayerSettingsParsed({
    required this.calcMethod,
    required this.madhab,
    required this.useGps,
    required this.manualLat,
    required this.manualLon,
    required this.manualLabel,
    required this.notificationsEnabled,
    required this.perPrayerNotifications,
    required this.startPrayerNotifications,
    required this.customEndMessages,
  });

  /// Default: Muslim World League + Hanafi + GPS + all notifications on.
  factory PrayerSettingsParsed.defaults() => PrayerSettingsParsed(
    calcMethod: 'muslimWorldLeague',
    madhab: 'hanafi',
    useGps: true,
    manualLat: 21.4225,
    manualLon: 39.8262,
    manualLabel: 'Mecca',
    notificationsEnabled: true,
    perPrayerNotifications: {for (final n in _fardKeys) n: true},
    startPrayerNotifications: {for (final n in _fardKeys) n: true},
    customEndMessages: {},
  );

  static const List<String> _fardKeys = [
    'fajr',
    'zuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  final String calcMethod;
  final String madhab;
  final bool useGps;
  final double manualLat;
  final double manualLon;
  final String manualLabel;
  final bool notificationsEnabled;

  /// End reminders, scheduled 10 minutes before each prayer window ends.
  final Map<String, bool> perPrayerNotifications;

  /// Start notifications, scheduled when each prayer window begins.
  final Map<String, bool> startPrayerNotifications;
  final Map<String, String> customEndMessages;

  bool notificationFor(PrayerName name) {
    final k = name.name;
    return perPrayerNotifications[k] ?? true;
  }

  bool startNotificationFor(PrayerName name) {
    final k = name.name;
    return startPrayerNotifications[k] ?? true;
  }

  String endMessageFor(PrayerName name) {
    final k = name.name;
    final custom = customEndMessages[k];
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    return '${_prettyPrayer(name)} time has ended. Did you pray?';
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

  /// Merge raw Firestore map with defaults (null-safe).
  factory PrayerSettingsParsed.fromRaw(Map<String, dynamic>? raw) {
    final d = PrayerSettingsParsed.defaults();
    if (raw == null || raw.isEmpty) return d;

    final per = Map<String, bool>.from(d.perPrayerNotifications);
    final incoming = raw['perPrayerNotifications'];
    if (incoming is Map) {
      for (final e in incoming.entries) {
        if (e.key is String && e.value is bool) {
          per[e.key as String] = e.value as bool;
        }
      }
    }

    final startPer = Map<String, bool>.from(d.startPrayerNotifications);
    final startIncoming = raw['startPrayerNotifications'];
    if (startIncoming is Map) {
      for (final e in startIncoming.entries) {
        if (e.key is String && e.value is bool) {
          startPer[e.key as String] = e.value as bool;
        }
      }
    }

    final custom = Map<String, String>.from(d.customEndMessages);
    final cm = raw['customEndMessages'];
    if (cm is Map) {
      for (final e in cm.entries) {
        if (e.key is String && e.value is String) {
          custom[e.key as String] = e.value as String;
        }
      }
    }

    return PrayerSettingsParsed(
      calcMethod: raw['calcMethod'] as String? ?? d.calcMethod,
      madhab: raw['madhab'] as String? ?? d.madhab,
      useGps: raw['useGps'] as bool? ?? d.useGps,
      manualLat: (raw['manualLat'] as num?)?.toDouble() ?? d.manualLat,
      manualLon: (raw['manualLon'] as num?)?.toDouble() ?? d.manualLon,
      manualLabel: raw['manualLabel'] as String? ?? d.manualLabel,
      notificationsEnabled:
          raw['notificationsEnabled'] as bool? ?? d.notificationsEnabled,
      perPrayerNotifications: per,
      startPrayerNotifications: startPer,
      customEndMessages: custom,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'calcMethod': calcMethod,
      'madhab': madhab,
      'useGps': useGps,
      'manualLat': manualLat,
      'manualLon': manualLon,
      'manualLabel': manualLabel,
      'notificationsEnabled': notificationsEnabled,
      'perPrayerNotifications': perPrayerNotifications,
      'startPrayerNotifications': startPrayerNotifications,
      'customEndMessages': customEndMessages,
    };
  }

  PrayerSettingsParsed copyWith({
    String? calcMethod,
    String? madhab,
    bool? useGps,
    double? manualLat,
    double? manualLon,
    String? manualLabel,
    bool? notificationsEnabled,
    Map<String, bool>? perPrayerNotifications,
    Map<String, bool>? startPrayerNotifications,
    Map<String, String>? customEndMessages,
  }) {
    return PrayerSettingsParsed(
      calcMethod: calcMethod ?? this.calcMethod,
      madhab: madhab ?? this.madhab,
      useGps: useGps ?? this.useGps,
      manualLat: manualLat ?? this.manualLat,
      manualLon: manualLon ?? this.manualLon,
      manualLabel: manualLabel ?? this.manualLabel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      perPrayerNotifications:
          perPrayerNotifications ?? Map.from(this.perPrayerNotifications),
      startPrayerNotifications:
          startPrayerNotifications ?? Map.from(this.startPrayerNotifications),
      customEndMessages: customEndMessages ?? Map.from(this.customEndMessages),
    );
  }

  static const List<String> calcMethodOptions = [
    'karachi',
    'muslimWorldLeague',
    'ummAlQura',
    'northAmerica',
    'egyptian',
    'tehran',
    'singapore',
  ];

  static String calcMethodLabel(String key) {
    return switch (key) {
      'karachi' => 'Karachi (UIS)',
      'muslimWorldLeague' => 'Muslim World League',
      'ummAlQura' => 'Umm al-Qura',
      'northAmerica' => 'ISNA (North America)',
      'egyptian' => 'Egyptian',
      'tehran' => 'Tehran',
      'singapore' => 'Singapore',
      _ => key,
    };
  }
}
