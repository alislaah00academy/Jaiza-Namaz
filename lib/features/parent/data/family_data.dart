import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../qaza/data/qaza_tracker.dart';

/// All Fard / Nawafil / Qaza logs for any tracked person — the signed-in
/// user or one of their children (children's logs use the child id as
/// `userId`, see [PrayerRepository]).
final personFardLogsProvider = StreamProvider.family<List<PrayerLog>, String>(
  (ref, uid) => ref.watch(prayerRepositoryProvider).watchAllFard(uid),
);

final personNawafilLogsProvider =
    StreamProvider.family<List<PrayerLog>, String>(
      (ref, uid) => ref
          .watch(prayerRepositoryProvider)
          .watchAllByType(uid, PrayerType.nawafil),
    );

final personQazaLogsProvider = StreamProvider.family<List<PrayerLog>, String>(
  (ref, uid) =>
      ref.watch(prayerRepositoryProvider).watchAllByType(uid, PrayerType.qaza),
);

/// Logs of [type] on one local day, keyed by prayer.
Map<PrayerName, PrayerLog> logsOnDay(List<PrayerLog> logs, DateTime day) {
  final key = AppDateUtils.localDateKey(day);
  return {
    for (final l in logs)
      if (AppDateUtils.localDateKey(l.dateTime) == key) l.prayerName: l,
  };
}

/// Number of Fard prayers completed on [day].
int fardDoneOn(List<PrayerLog> logs, DateTime day) {
  final map = logsOnDay(logs, day);
  return kFardPrayerDefs
      .where((d) => map[d.name]?.status == PrayerStatus.completed)
      .length;
}

/// Local date keys in [month] where every Fard prayer was completed —
/// the calendar dot, computed from an arbitrary log list (self or child).
Set<String> fullFardDayKeysForMonth(List<PrayerLog> logs, DateTime month) {
  final byDay = <String, Set<PrayerName>>{};
  for (final l in logs) {
    if (l.status != PrayerStatus.completed) continue;
    final ld = l.dateTime.toLocal();
    if (ld.year != month.year || ld.month != month.month) continue;
    byDay.putIfAbsent(AppDateUtils.localDateKey(ld), () => {}).add(l.prayerName);
  }
  final full = <String>{};
  for (final e in byDay.entries) {
    if (kFardPrayerDefs.every((d) => e.value.contains(d.name))) full.add(e.key);
  }
  return full;
}

/// Completed Fard in the last 7 days (today included).
int fardDoneThisWeek(List<PrayerLog> logs) {
  final now = DateTime.now();
  var sum = 0;
  for (var i = 0; i < 7; i++) {
    sum += fardDoneOn(logs, DateTime(now.year, now.month, now.day - i));
  }
  return sum;
}

/// (current, best) run of days with all five Fard prayed. The current run
/// may end yesterday, since today is still in progress.
(int, int) fardStreak(List<PrayerLog> logs) {
  final full = <String>{};
  final byDay = <String, Set<PrayerName>>{};
  for (final l in logs) {
    if (l.status != PrayerStatus.completed) continue;
    byDay
        .putIfAbsent(AppDateUtils.localDateKey(l.dateTime), () => {})
        .add(l.prayerName);
  }
  for (final e in byDay.entries) {
    if (kFardPrayerDefs.every((d) => e.value.contains(d.name))) full.add(e.key);
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var d = full.contains(AppDateUtils.localDateKey(today))
      ? today
      : today.subtract(const Duration(days: 1));
  var current = 0;
  while (full.contains(AppDateUtils.localDateKey(d))) {
    current++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  final sorted = full.toList()..sort();
  var best = 0, run = 0;
  DateTime? prev;
  for (final k in sorted) {
    final day = DateTime.parse(k);
    run = prev != null && day.difference(prev).inDays == 1 ? run + 1 : 1;
    if (run > best) best = run;
    prev = day;
  }
  return (current, best);
}

/// Age and gender for a child — not in the children backend yet, so kept
/// on the device.
class ChildExtra {
  const ChildExtra({this.age, this.gender});

  final int? age;

  /// 'boy' or 'girl'.
  final String? gender;

  String get label => [
    if (age != null) '$age ${age == 1 ? 'year' : 'years'}',
    if (gender == 'boy') 'Boy',
    if (gender == 'girl') 'Girl',
  ].join(' · ');

  Map<String, dynamic> toJson() => {'age': age, 'gender': gender};

  static ChildExtra fromJson(Map<String, dynamic> j) =>
      ChildExtra(age: (j['age'] as num?)?.toInt(), gender: j['gender'] as String?);
}

class ChildExtrasNotifier extends StateNotifier<Map<String, ChildExtra>> {
  ChildExtrasNotifier(this._prefs) : super(_read(_prefs));

  static const _key = 'jz_child_extras_v1';
  final dynamic _prefs;

  static Map<String, ChildExtra> _read(dynamic prefs) {
    final raw = prefs.getString(_key) as String?;
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map(
        (k, v) => MapEntry(k, ChildExtra.fromJson(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> set(String childId, ChildExtra extra) async {
    state = {...state, childId: extra};
    await _prefs.setString(
      _key,
      jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}

final childExtrasProvider =
    StateNotifierProvider<ChildExtrasNotifier, Map<String, ChildExtra>>(
      (ref) => ChildExtrasNotifier(ref.watch(sharedPrefsProvider)),
    );

ChildProfile? childById(List<ChildProfile> children, String? id) {
  for (final c in children) {
    if (c.id == id) return c;
  }
  return null;
}

/// A child's Qaza, counted from the day they were added.
final childQazaOverviewProvider = Provider.family<QazaOverview, String>((
  ref,
  childId,
) {
  final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
  final child = childById(children, childId);
  final createdAt = child?.createdAt;
  final since = createdAt == null
      ? ref.watch(qazaTrackingSinceProvider)
      : DateTime(createdAt.year, createdAt.month, createdAt.day);
  return buildQazaOverview(
    since: since,
    fardLogs: ref.watch(personFardLogsProvider(childId)).valueOrNull ?? const [],
    qazaLogs: ref.watch(personQazaLogsProvider(childId)).valueOrNull ?? const [],
    schedule: ref.watch(currentPrayerCardProvider).valueOrNull?.today,
  );
});

/// True when a child has a prayer from today whose window ended unmarked —
/// the red dot on their chip.
final childNeedsAttentionProvider = Provider.family<bool, String>((
  ref,
  childId,
) {
  final logs = ref.watch(personFardLogsProvider(childId)).valueOrNull ?? const [];
  final schedule = ref.watch(currentPrayerCardProvider).valueOrNull?.today;
  if (schedule == null) return false;
  final map = logsOnDay(logs, DateTime.now());
  final now = DateTime.now();
  return kFardPrayerDefs.any(
    (d) =>
        schedule.endTimeFor(d.name).isBefore(now) &&
        map[d.name]?.status != PrayerStatus.completed,
  );
});

/// Family reminder preferences (on-device until a backend exists).
class FamilyReminderPrefs {
  const FamilyReminderPrefs(this.values);

  final Map<String, dynamic> values;

  bool flag(String k, [bool fallback = true]) =>
      values[k] as bool? ?? fallback;
  int number(String k, int fallback) => (values[k] as num?)?.toInt() ?? fallback;
  Set<String> set(String k, Set<String> fallback) =>
      (values[k] as List?)?.cast<String>().toSet() ?? fallback;
}

class FamilyReminderNotifier extends StateNotifier<FamilyReminderPrefs> {
  FamilyReminderNotifier(this._prefs)
    : super(FamilyReminderPrefs(_read(_prefs)));

  static const _key = 'jz_family_reminders_v1';
  final dynamic _prefs;

  static Map<String, dynamic> _read(dynamic prefs) {
    final raw = prefs.getString(_key) as String?;
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> put(String k, Object value) async {
    state = FamilyReminderPrefs({...state.values, k: value});
    await _prefs.setString(_key, jsonEncode(state.values));
  }
}

final familyReminderPrefsProvider =
    StateNotifierProvider<FamilyReminderNotifier, FamilyReminderPrefs>(
      (ref) => FamilyReminderNotifier(ref.watch(sharedPrefsProvider)),
    );
