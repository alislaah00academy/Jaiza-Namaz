import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaiza_core/jaiza_core.dart' show SubjectRef;

import '../models/streak_stats.dart';

/// `{subject}/stats/streak` (06 §2.4) — Function-written (D-071, 09 §5); the
/// client only reads it. Recomputing streaks/badges client-side was removed
/// when `onPrayerWritten` took over (08 §2.2).
class StreakRepository {
  StreakRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<StreakStats?> watchStreaks(SubjectRef subject) {
    return _firestore
        .doc(subject.statsStreakPath)
        .snapshots()
        .map(StreakStats.fromSnapshot);
  }
}
