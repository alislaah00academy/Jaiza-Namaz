import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `streaks/{userId}`.
class StreakStats {
  const StreakStats({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastFardPerfectDate,
    this.badgesUnlocked = const [],
  });

  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastFardPerfectDate;
  final List<String> badgesUnlocked;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (lastFardPerfectDate != null) 'lastFardPerfectDate': lastFardPerfectDate,
      'badgesUnlocked': badgesUnlocked,
    };
  }

  static StreakStats empty(String uid) => StreakStats(
        userId: uid,
        currentStreak: 0,
        longestStreak: 0,
        badgesUnlocked: const [],
      );

  static StreakStats? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return null;
    final badges = data['badgesUnlocked'];
    return StreakStats(
      userId: data['userId'] as String? ?? snap.id,
      currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
      lastFardPerfectDate: data['lastFardPerfectDate'] as String?,
      badgesUnlocked: badges is List
          ? badges.map((e) => e.toString()).toList()
          : const [],
    );
  }

  static StreakStats fromJson(Map<String, dynamic> data, String userId) {
    final badges = data['badgesUnlocked'];
    return StreakStats(
      userId: data['userId'] as String? ?? userId,
      currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
      lastFardPerfectDate: data['lastFardPerfectDate'] as String?,
      badgesUnlocked: badges is List
          ? badges.map((e) => e.toString()).toList()
          : const [],
    );
  }
}
