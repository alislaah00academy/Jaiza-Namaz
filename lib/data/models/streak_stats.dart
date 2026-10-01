import 'package:cloud_firestore/cloud_firestore.dart';

/// `{subject}/stats/streak` (06 §2.4), Function-written. Field names here
/// predate the backend rewrite and are kept to avoid touching every screen
/// that reads them; they map onto the new doc's `current`/`longest`/
/// `lastPerfectDateKey`/`badges`/`nawafilTotal`.
class StreakStats {
  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    this.lastFardPerfectDate,
    this.badgesUnlocked = const [],
    this.nawafilTotal = 0,
  });

  final int currentStreak;
  final int longestStreak;
  final String? lastFardPerfectDate;
  final List<String> badgesUnlocked;
  final int nawafilTotal;

  static StreakStats? fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    final badges = data['badges'];
    return StreakStats(
      currentStreak: (data['current'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longest'] as num?)?.toInt() ?? 0,
      lastFardPerfectDate: data['lastPerfectDateKey'] as String?,
      badgesUnlocked: badges is List
          ? badges.map((e) => e.toString()).toList()
          : const [],
      nawafilTotal: (data['nawafilTotal'] as num?)?.toInt() ?? 0,
    );
  }
}
