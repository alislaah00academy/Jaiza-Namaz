import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/prayer_catalog.dart';
import '../../core/logging/app_log.dart';
import '../../core/utils/date_utils.dart';
import '../models/badge_definitions.dart';
import '../models/prayer_log.dart';
import '../models/streak_stats.dart';

/// Firestore `streaks/{userId}` — Fard daily streak + badges.
class StreakRepository {
  StreakRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _streaks =>
      _firestore.collection('streaks');

  CollectionReference<Map<String, dynamic>> get _prayers =>
      _firestore.collection('prayers');

  Stream<StreakStats?> watchStreaks(String uid) {
    return _streaks.doc(uid).snapshots().map(StreakStats.fromSnapshot);
  }

  /// Called after any Fard log upsert.
  Future<void> recomputeAfterFardChange(String userId) async {
    try {
      final todayKey = AppDateUtils.localDateKey(DateTime.now());
      var allComplete = true;
      for (final def in kFardPrayerDefs) {
        final id = PrayerLog.deterministicId(
          userId: userId,
          localDateKey: todayKey,
          prayerName: def.name,
          type: PrayerType.fard,
        );
        final snap = await _prayers.doc(id).get();
        if (!snap.exists) {
          allComplete = false;
          break;
        }
        final log = PrayerLog.fromFirestore(snap);
        if (log == null || log.status != PrayerStatus.completed) {
          allComplete = false;
          break;
        }
      }
      if (!allComplete) return;

      final streakRef = _streaks.doc(userId);
      await _firestore.runTransaction((tx) async {
        final s = await tx.get(streakRef);
        final prev = s.exists && s.data() != null
            ? StreakStats.fromSnapshot(s)
            : null;
        var current = prev?.currentStreak ?? 0;
        var longest = prev?.longestStreak ?? 0;
        final last = prev?.lastFardPerfectDate;

        if (last == todayKey) {
          return;
        }

        final yesterdayKey = AppDateUtils.localDateKey(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        if (last == null) {
          current = 1;
        } else if (last == yesterdayKey) {
          current = current + 1;
        } else {
          current = 1;
        }
        if (current > longest) longest = current;

        final badges = List<String>.from(prev?.badgesUnlocked ?? []);
        for (final b in kBadgeDefinitions) {
          if (b.minStreak > 0 && current >= b.minStreak) {
            if (!badges.contains(b.id)) badges.add(b.id);
          }
        }

        tx.set(
          streakRef,
          {
            'userId': userId,
            'currentStreak': current,
            'longestStreak': longest,
            'lastFardPerfectDate': todayKey,
            'badgesUnlocked': badges,
          },
          SetOptions(merge: true),
        );
      });

      await _maybeUnlockNawafilBadge(userId);
    } catch (e, st) {
      appLog('recomputeAfterFardChange', error: e, stackTrace: st);
    }
  }

  /// Call after a nawafil prayer is marked completed.
  Future<void> refreshNawafilBadge(String userId) =>
      _maybeUnlockNawafilBadge(userId);

  Future<void> _maybeUnlockNawafilBadge(String userId) async {
    try {
      final q = await _prayers
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: PrayerType.nawafil.firestoreValue)
          .where('status', isEqualTo: PrayerStatus.completed.firestoreValue)
          .limit(20)
          .get();
      if (q.docs.length < 10) return;

      final streakRef = _streaks.doc(userId);
      await streakRef.set(
        {
          'badgesUnlocked': FieldValue.arrayUnion(['nawafil_nur']),
        },
        SetOptions(merge: true),
      );
    } catch (e, st) {
      appLog('_maybeUnlockNawafilBadge', error: e, stackTrace: st);
    }
  }

  Future<void> ensureStreakDoc(String userId) async {
    try {
      final ref = _streaks.doc(userId);
      final snap = await ref.get();
      if (snap.exists) return;
      await ref.set(StreakStats.empty(userId).toJson());
    } catch (e, st) {
      appLog('ensureStreakDoc', error: e, stackTrace: st);
    }
  }
}
