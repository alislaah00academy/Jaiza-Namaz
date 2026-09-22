import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device storage for the redesigned features that have no Firestore
/// backend yet (primary/saved mosques, Jama'at alerts, Qaza helpers).
/// Overridden in `main()` with the already-loaded instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

abstract final class LocalKeys {
  static const primaryMosque = 'jz_primary_mosque_v1';
  static const savedMosques = 'jz_saved_mosques_v1';
  static const mosqueSetupSeen = 'jz_mosque_setup_seen_v1';
  static const jamaatAlertsOn = 'jz_jamaat_alerts_on_v1';
  static const jamaatAlertMinutes = 'jz_jamaat_alert_minutes_v1';
  static const jamaatAlertMosques = 'jz_jamaat_alert_mosques_v1';
  static const qazaIntroDone = 'jz_qaza_intro_done_v1';
  static const qazaRemindDaily = 'jz_qaza_remind_daily_v1';
  static const trackingSince = 'jz_tracking_since_v1';
}

/// A persisted nullable string (e.g. the primary mosque id).
class StringPref extends StateNotifier<String?> {
  StringPref(this._prefs, this._key) : super(_prefs.getString(_key));

  final SharedPreferences _prefs;
  final String _key;

  Future<void> set(String? value) async {
    state = value;
    if (value == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, value);
    }
  }
}

/// A persisted set of strings (saved mosques, alert mosques).
class SetPref extends StateNotifier<Set<String>> {
  SetPref(this._prefs, this._key)
    : super((_prefs.getStringList(_key) ?? const []).toSet());

  final SharedPreferences _prefs;
  final String _key;

  Future<void> toggle(String id, [bool? on]) async {
    final next = {...state};
    final add = on ?? !next.contains(id);
    add ? next.add(id) : next.remove(id);
    state = next;
    await _prefs.setStringList(_key, next.toList());
  }
}

class BoolPref extends StateNotifier<bool> {
  BoolPref(this._prefs, this._key, bool fallback)
    : super(_prefs.getBool(_key) ?? fallback);

  final SharedPreferences _prefs;
  final String _key;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
}

class IntPref extends StateNotifier<int> {
  IntPref(this._prefs, this._key, int fallback)
    : super(_prefs.getInt(_key) ?? fallback);

  final SharedPreferences _prefs;
  final String _key;

  Future<void> set(int value) async {
    state = value;
    await _prefs.setInt(_key, value);
  }
}

final primaryMosqueIdProvider = StateNotifierProvider<StringPref, String?>(
  (ref) => StringPref(ref.watch(sharedPrefsProvider), LocalKeys.primaryMosque),
);

final savedMosqueIdsProvider = StateNotifierProvider<SetPref, Set<String>>(
  (ref) => SetPref(ref.watch(sharedPrefsProvider), LocalKeys.savedMosques),
);

final mosqueSetupSeenProvider = StateNotifierProvider<BoolPref, bool>(
  (ref) => BoolPref(
    ref.watch(sharedPrefsProvider),
    LocalKeys.mosqueSetupSeen,
    false,
  ),
);

final jamaatAlertsOnProvider = StateNotifierProvider<BoolPref, bool>(
  (ref) =>
      BoolPref(ref.watch(sharedPrefsProvider), LocalKeys.jamaatAlertsOn, true),
);

final jamaatAlertMinutesProvider = StateNotifierProvider<IntPref, int>(
  (ref) =>
      IntPref(ref.watch(sharedPrefsProvider), LocalKeys.jamaatAlertMinutes, 10),
);

final jamaatAlertMosquesProvider = StateNotifierProvider<SetPref, Set<String>>(
  (ref) =>
      SetPref(ref.watch(sharedPrefsProvider), LocalKeys.jamaatAlertMosques),
);

final qazaIntroDoneProvider = StateNotifierProvider<BoolPref, bool>(
  (ref) =>
      BoolPref(ref.watch(sharedPrefsProvider), LocalKeys.qazaIntroDone, false),
);

final qazaRemindDailyProvider = StateNotifierProvider<BoolPref, bool>(
  (ref) =>
      BoolPref(ref.watch(sharedPrefsProvider), LocalKeys.qazaRemindDaily, true),
);

/// First day this install started counting missed prayers — the fallback
/// when the account has no `createdAt`. Written once, on first read.
final localTrackingSinceProvider = Provider<DateTime>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final raw = prefs.getString(LocalKeys.trackingSince);
  final parsed = raw == null ? null : DateTime.tryParse(raw);
  if (parsed != null) return parsed;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  prefs.setString(LocalKeys.trackingSince, today.toIso8601String());
  return today;
});
