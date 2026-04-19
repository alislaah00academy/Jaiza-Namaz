/// In-app badge metadata; unlock state lives in Firestore on [StreakStats.badgesUnlocked].
class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.minStreak,
  });

  final String id;
  final String title;
  final String description;
  final int minStreak;
}

const List<BadgeDefinition> kBadgeDefinitions = [
  BadgeDefinition(
    id: 'first_step',
    title: 'First step',
    description: 'Complete all Fard prayers for one day.',
    minStreak: 1,
  ),
  BadgeDefinition(
    id: 'week_warrior',
    title: 'Week warrior',
    description: '7-day Fard streak.',
    minStreak: 7,
  ),
  BadgeDefinition(
    id: 'month_light',
    title: 'Month of light',
    description: '30-day Fard streak.',
    minStreak: 30,
  ),
  BadgeDefinition(
    id: 'nawafil_nur',
    title: 'Nawafil Nur',
    description: 'Offer nawafil 10 times (tracked).',
    minStreak: 0,
  ),
];
