import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jaiza_core/jaiza_core.dart' show PrayerLogSource;

import '../../core/analytics/analytics.dart';
import '../../core/constants/prayer_catalog.dart';
import '../../core/logging/app_log.dart';
import '../../core/utils/date_utils.dart';
import '../../services/notifications_service.dart';
import '../models/prayer_log.dart';
import 'streak_repository.dart';

/// Top-level `prayers` collection with deterministic document ids.
class PrayerRepository {
  PrayerRepository(
    this._firestore, {
    StreakRepository? streakRepository,
    Analytics? analytics,
  }) : _streakRepository = streakRepository,
       _analytics = analytics;

  final FirebaseFirestore _firestore;
  final StreakRepository? _streakRepository;
  final Analytics? _analytics;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('prayers');

  /// Upsert today's log for this prayer; then refresh Fard streak stats.
  Future<void> upsertPrayer({
    required String userId,
    required PrayerName prayerName,
    required PrayerType type,
    required PrayerStatus status,
    String? ownerUid,

    /// Day to record for; defaults to now. Lets Records edit past days.
    DateTime? at,

    /// For analytics only. Defaults to self when [ownerUid] is null, else
    /// child (Parent mode); class marking passes student.
    AnalyticsSubject? subject,

    /// For analytics only. Defaults from [subject] (guardian / teacher / app).
    PrayerLogSource? source,
  }) async {
    try {
      final now = at ?? DateTime.now();
      final dateKey = AppDateUtils.localDateKey(now);
      final id = PrayerLog.deterministicId(
        userId: userId,
        localDateKey: dateKey,
        prayerName: prayerName,
        type: type,
      );
      final log = PrayerLog(
        id: id,
        userId: userId,
        prayerName: prayerName,
        type: type,
        status: status,
        dateTime: now,
        ownerUid: ownerUid,
      );
      await _col.doc(id).set(log.toFirestore(), SetOptions(merge: true));
      _logMarked(
        prayerName: prayerName,
        type: type,
        status: status,
        subject:
            subject ??
            (ownerUid == null ? AnalyticsSubject.self : AnalyticsSubject.child),
        source: source,
      );
      if (type == PrayerType.fard && status == PrayerStatus.completed) {
        await NotificationsService.instance.cancelForPrayer(now, prayerName);
      }
      if (type == PrayerType.fard) {
        await _streakRepository?.recomputeAfterFardChange(userId);
      } else if (type == PrayerType.nawafil &&
          status == PrayerStatus.completed) {
        await _streakRepository?.refreshNawafilBadge(userId);
      }
    } catch (e, st) {
      appLog('upsertPrayer', error: e, stackTrace: st);
      rethrow;
    }
  }

  void _logMarked({
    required PrayerName prayerName,
    required PrayerType type,
    required PrayerStatus status,
    required AnalyticsSubject subject,
    PrayerLogSource? source,
  }) {
    final a = _analytics;
    if (a == null) return;
    if (type == PrayerType.qaza) {
      // Each Qaza log is one made-up prayer.
      a.qazaLogged(prayer: prayerName, delta: 1);
      return;
    }
    a.prayerMarked(
      prayer: prayerName,
      type: type,
      status: status,
      subject: subject,
      source:
          source ??
          switch (subject) {
            AnalyticsSubject.self => PrayerLogSource.app,
            AnalyticsSubject.child => PrayerLogSource.guardian,
            AnalyticsSubject.student => PrayerLogSource.teacher,
          },
    );
  }

  /// All Fard logs for this user (client-side filtering by day/month).
  Stream<List<PrayerLog>> watchAllFard(String userId) {
    return watchAllByType(userId, PrayerType.fard);
  }

  /// All logs of [type] for this user (client-side filtering by day/month).
  /// Generalizes [watchAllFard] for Nawafil/Qaza history views.
  Stream<List<PrayerLog>> watchAllByType(String userId, PrayerType type) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.firestoreValue)
        .snapshots()
        .map((snap) {
          final list = <PrayerLog>[];
          for (final doc in snap.docs) {
            final log = PrayerLog.fromFirestore(doc);
            if (log != null) list.add(log);
          }
          return list;
        });
  }

  /// Stream merged state for today's Fard prayers (6 docs).
  Stream<Map<PrayerName, PrayerLog>> watchTodayFard(String userId) {
    final names = kFardPrayerDefs.map((e) => e.name).toList();
    return _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: PrayerType.fard.firestoreValue)
        .where(
          'prayerName',
          whereIn: names.map((n) => n.firestoreValue).toList(),
        )
        .snapshots()
        .map((snap) {
          final dateKey = AppDateUtils.localDateKey(DateTime.now());
          final map = <PrayerName, PrayerLog>{};
          for (final doc in snap.docs) {
            final log = PrayerLog.fromFirestore(doc);
            if (log == null) continue;
            final key = AppDateUtils.localDateKey(log.dateTime);
            if (key != dateKey) continue;
            map[log.prayerName] = log;
          }
          return map;
        });
  }

  /// Today's nawafil logs (same day filter client-side).
  Stream<List<PrayerLog>> watchTodayNawafil(String userId) {
    final names = kNawafilDefs.map((e) => e.name.firestoreValue).toList();
    return _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: PrayerType.nawafil.firestoreValue)
        .where('prayerName', whereIn: names)
        .snapshots()
        .map((snap) {
          final today = AppDateUtils.localDateKey(DateTime.now());
          final list = <PrayerLog>[];
          for (final doc in snap.docs) {
            final log = PrayerLog.fromFirestore(doc);
            if (log == null) continue;
            if (AppDateUtils.localDateKey(log.dateTime) == today) {
              list.add(log);
            }
          }
          return list;
        });
  }

  /// All-time count of completed nawafil (for badges). Cap query with count aggregation optional — simple snapshot size for MVP.
  Future<int> countCompletedNawafil(String userId) async {
    try {
      final q = await _col
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: PrayerType.nawafil.firestoreValue)
          .where('status', isEqualTo: PrayerStatus.completed.firestoreValue)
          .get();
      return q.docs.length;
    } catch (e, st) {
      appLog('countCompletedNawafil', error: e, stackTrace: st);
      return 0;
    }
  }

  /// Completed qaza count (all time).
  Future<int> countCompletedQaza(String userId) async {
    try {
      final q = await _col
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: PrayerType.qaza.firestoreValue)
          .where('status', isEqualTo: PrayerStatus.completed.firestoreValue)
          .get();
      return q.docs.length;
    } catch (e, st) {
      appLog('countCompletedQaza', error: e, stackTrace: st);
      return 0;
    }
  }

  /// Today's completed qaza count (client-side day filter to avoid extra indexes).
  Future<int> countTodayQaza(String userId) async {
    try {
      final q = await _col
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: PrayerType.qaza.firestoreValue)
          .where('status', isEqualTo: PrayerStatus.completed.firestoreValue)
          .get();
      final today = AppDateUtils.localDateKey(DateTime.now());
      var n = 0;
      for (final doc in q.docs) {
        final log = PrayerLog.fromFirestore(doc);
        if (log != null && AppDateUtils.localDateKey(log.dateTime) == today) {
          n++;
        }
      }
      return n;
    } catch (e, st) {
      appLog('countTodayQaza', error: e, stackTrace: st);
      return 0;
    }
  }
}
