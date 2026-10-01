import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jaiza_core/jaiza_core.dart';

import '../../core/analytics/analytics.dart';
import '../../core/logging/app_log.dart';
import '../../services/notifications_service.dart';
import '../models/prayer_log.dart';

/// `{subject}/prayers` subcollections (06 §2.2, D-072) — `subject` is
/// `users/{uid}`, `children/{id}` or `students/{id}`, chosen by the caller's
/// [SubjectRef]. Streak/Qaza stats are Function-written; this repository
/// only writes logs and reads them back.
class PrayerRepository {
  PrayerRepository(this._firestore, {Analytics? analytics})
    : _analytics = analytics;

  final FirebaseFirestore _firestore;
  final Analytics? _analytics;

  CollectionReference<Map<String, dynamic>> _col(SubjectRef subject) =>
      _firestore.collection(subject.prayersPath);

  /// Upsert a Fard/Nawafil log for [subject].
  Future<void> upsertPrayer({
    required SubjectRef subject,

    /// uid of whoever is marking (rules require `markedBy == auth.uid`): the
    /// subject themself, a guardian, or a teacher.
    required String markedBy,
    required PrayerName prayerName,
    required PrayerType type,
    required PrayerStatus status,

    /// Day to record for; defaults to now. Lets Records edit past days.
    DateTime? at,

    /// For analytics only. Defaults to self when [subject] is [SelfSubject].
    AnalyticsSubject? analyticsSubject,

    /// For analytics only, and stored as `source`. Defaults from [subject].
    PrayerLogSource? source,
  }) async {
    try {
      final now = at ?? DateTime.now();
      final effectiveSource = source ?? _defaultSource(subject);
      final id = prayerLogId(DateKeys.of(now), prayerName, type);
      await _col(subject)
          .doc(id)
          .set(
            prayerLogWriteData(
              prayerName: prayerName,
              type: type,
              status: status,
              markedBy: markedBy,
              source: effectiveSource,
              dateTime: now,
            ),
          );
      _logMarked(
        prayerName: prayerName,
        type: type,
        status: status,
        subject: analyticsSubject ?? _analyticsSubjectFor(subject),
        source: effectiveSource,
      );
      if (type == PrayerType.fard && status == PrayerStatus.completed) {
        await NotificationsService.instance.cancelForPrayer(now, prayerName);
      }
    } catch (e, st) {
      appLog('upsertPrayer', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Records one made-up Qaza for [subject]/[prayerName] "today" — the
  /// repository keeps one log per subject/day/prayer, so repeated taps
  /// accumulate in that log's `count` (09 §4.2; rules cap it at 50).
  Future<void> incrementQaza({
    required SubjectRef subject,
    required String markedBy,
    required PrayerName prayerName,
    int delta = 1,
    DateTime? at,
    PrayerLogSource? source,
  }) async {
    try {
      final now = at ?? DateTime.now();
      final effectiveSource = source ?? _defaultSource(subject);
      final id = prayerLogId(DateKeys.of(now), prayerName, PrayerType.qaza);
      await _col(subject).doc(id).set({
        ...prayerLogWriteData(
          prayerName: prayerName,
          type: PrayerType.qaza,
          markedBy: markedBy,
          source: effectiveSource,
          dateTime: now,
        ),
        'count': FieldValue.increment(delta),
      }, SetOptions(merge: true));
      _analytics?.qazaLogged(prayer: prayerName, delta: delta);
    } catch (e, st) {
      appLog('incrementQaza', error: e, stackTrace: st);
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
    _analytics?.prayerMarked(
      prayer: prayerName,
      type: type,
      status: status,
      subject: subject,
      source: source ?? PrayerLogSource.app,
    );
  }

  AnalyticsSubject _analyticsSubjectFor(SubjectRef subject) =>
      switch (subject) {
        SelfSubject() => AnalyticsSubject.self,
        ChildSubject() => AnalyticsSubject.child,
        StudentSubject() => AnalyticsSubject.student,
      };

  PrayerLogSource _defaultSource(SubjectRef subject) => switch (subject) {
    SelfSubject() => PrayerLogSource.app,
    ChildSubject() => PrayerLogSource.guardian,
    StudentSubject() => PrayerLogSource.teacher,
  };

  /// All Fard logs for [subject] (client-side filtering by day/month).
  Stream<List<PrayerLog>> watchAllFard(SubjectRef subject) {
    return watchAllByType(subject, PrayerType.fard);
  }

  /// All logs of [type] for [subject] (client-side filtering by day/month).
  Stream<List<PrayerLog>> watchAllByType(SubjectRef subject, PrayerType type) {
    return _col(subject)
        .where('type', isEqualTo: type.firestoreValue)
        .snapshots()
        .map((snap) => snap.docs.map(prayerLogFromSnapshot).nonNulls.toList());
  }

  /// Stream merged state for today's Fard prayers (single `dateKey` query).
  Stream<Map<PrayerName, PrayerLog>> watchTodayFard(SubjectRef subject) {
    return _col(subject)
        .where('dateKey', isEqualTo: DateKeys.of(DateTime.now()))
        .where('type', isEqualTo: PrayerType.fard.firestoreValue)
        .snapshots()
        .map((snap) {
          final map = <PrayerName, PrayerLog>{};
          for (final doc in snap.docs) {
            final log = prayerLogFromSnapshot(doc);
            if (log != null) map[log.prayerName] = log;
          }
          return map;
        });
  }

  /// Today's nawafil logs.
  Stream<List<PrayerLog>> watchTodayNawafil(SubjectRef subject) {
    return _col(subject)
        .where('dateKey', isEqualTo: DateKeys.of(DateTime.now()))
        .where('type', isEqualTo: PrayerType.nawafil.firestoreValue)
        .snapshots()
        .map((snap) => snap.docs.map(prayerLogFromSnapshot).nonNulls.toList());
  }
}
