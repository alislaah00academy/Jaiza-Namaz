import '../../core/l10n/l10n.dart';

/// In-app badge metadata; unlock state lives in Firestore on [StreakStats.badgesUnlocked].
class BadgeDefinition {
  const BadgeDefinition({required this.id, required this.minStreak});

  final String id;
  final int minStreak;

  String title(L10n l) => switch (id) {
    'first_step' => l.badgeFirstStepTitle,
    'week_warrior' => l.badgeWeekWarriorTitle,
    'month_light' => l.badgeMonthOfLightTitle,
    _ => l.badgeNawafilNurTitle,
  };

  String description(L10n l) => switch (id) {
    'first_step' => l.badgeFirstStepDescription,
    'week_warrior' => l.badgeWeekWarriorDescription,
    'month_light' => l.badgeMonthOfLightDescription,
    _ => l.badgeNawafilNurDescription,
  };
}

const List<BadgeDefinition> kBadgeDefinitions = [
  BadgeDefinition(id: 'first_step', minStreak: 1),
  BadgeDefinition(id: 'week_warrior', minStreak: 7),
  BadgeDefinition(id: 'month_light', minStreak: 30),
  BadgeDefinition(id: 'nawafil_nur', minStreak: 0),
];
