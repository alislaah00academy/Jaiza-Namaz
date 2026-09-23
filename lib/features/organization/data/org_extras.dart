import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/local/local_prefs.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Everything the org screens need that has no backend field yet (a
/// class's optional "section" label, and teacher-only reminder prefs) plus
/// small aggregates computed client-side from the existing per-student
/// prayer streams — no new Firestore reads beyond what already exists.

/// Optional free-text section per class (e.g. "Dars-e-Nizami year 2"),
/// kept on the teacher's device.
class ClassSectionsNotifier extends StateNotifier<Map<String, String>> {
  ClassSectionsNotifier(this._prefs) : super(_read(_prefs));

  static const _key = 'jz_class_sections_v1';
  final dynamic _prefs;

  static Map<String, String> _read(dynamic prefs) {
    final raw = prefs.getStringList(_key) as List<String>?;
    if (raw == null) return {};
    final map = <String, String>{};
    for (final entry in raw) {
      final i = entry.indexOf('\u0001');
      if (i < 0) continue;
      map[entry.substring(0, i)] = entry.substring(i + 1);
    }
    return map;
  }

  Future<void> set(String classId, String section) async {
    final next = {...state};
    if (section.trim().isEmpty) {
      next.remove(classId);
    } else {
      next[classId] = section.trim();
    }
    state = next;
    await _prefs.setStringList(_key, [
      for (final e in next.entries) '${e.key}\u0001${e.value}',
    ]);
  }
}

final classSectionsProvider =
    StateNotifierProvider<ClassSectionsNotifier, Map<String, String>>(
      (ref) => ClassSectionsNotifier(ref.watch(sharedPrefsProvider)),
    );

/// Teacher-only "Class reminders" prefs (unmarked-class nudge). On-device;
/// no push-scheduling backend yet, same as Family reminders.
final classRemindersOnProvider = StateNotifierProvider<BoolPref, bool>(
  (ref) => BoolPref(
    ref.watch(sharedPrefsProvider),
    'jz_class_reminders_on_v1',
    true,
  ),
);

final classReminderMinutesProvider = StateNotifierProvider<IntPref, int>(
  (ref) =>
      IntPref(ref.watch(sharedPrefsProvider), 'jz_class_reminder_min_v1', 20),
);

final mutedClassesProvider = StateNotifierProvider<SetPref, Set<String>>(
  (ref) => SetPref(ref.watch(sharedPrefsProvider), 'jz_muted_classes_v1'),
);

/// How many of [studentIds] have [prayer] marked completed today, out of
/// the total. [ref] is a `WidgetRef` or `Ref` — both expose `.watch`.
(int, int) classPrayerCount(
  dynamic ref,
  List<String> studentIds,
  PrayerName prayer,
) {
  var done = 0;
  for (final id in studentIds) {
    final map =
        ref.watch(studentTodayFardMapProvider(id)).valueOrNull ?? const {};
    if (map[prayer]?.status == PrayerStatus.completed) done++;
  }
  return (done, studentIds.length);
}

/// Average of (prayers completed today / 5) across [studentIds], 0..1.
double classTodayFraction(dynamic ref, List<String> studentIds) {
  if (studentIds.isEmpty) return 0;
  var sum = 0.0;
  for (final id in studentIds) {
    final map =
        ref.watch(studentTodayFardMapProvider(id)).valueOrNull ?? const {};
    final done = kFardPrayerDefs
        .where((d) => map[d.name]?.status == PrayerStatus.completed)
        .length;
    sum += done / kFardPrayerDefs.length;
  }
  return sum / studentIds.length;
}
