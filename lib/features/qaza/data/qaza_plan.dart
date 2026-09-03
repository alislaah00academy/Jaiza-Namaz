import '../../../data/models/prayer_log.dart';

/// The five obligatory (Fard) prayer names tracked individually for Qaza
/// make-up — same list as [kFardPrayerDefs], kept as a constant here so
/// qaza_plan.dart has no dependency on the catalog's display-label structure.
const List<PrayerName> kQazaPrayerNames = [
  PrayerName.fajr,
  PrayerName.zuhr,
  PrayerName.asr,
  PrayerName.maghrib,
  PrayerName.isha,
];

/// How often the user wants to be reminded to make up a given prayer's
/// Qaza backlog. Stored as a preference now; actual recurring-notification
/// scheduling is a separate, not-yet-built feature.
enum QazaFrequency { daily, weekly, monthly, yearly, custom }

extension QazaFrequencyX on QazaFrequency {
  String get firestoreValue => name;

  String get label => switch (this) {
    QazaFrequency.daily => 'Daily',
    QazaFrequency.weekly => 'Weekly',
    QazaFrequency.monthly => 'Monthly',
    QazaFrequency.yearly => 'Yearly',
    QazaFrequency.custom => 'Custom',
  };

  String get hint => switch (this) {
    QazaFrequency.daily => 'Every day',
    QazaFrequency.weekly => 'Once a week',
    QazaFrequency.monthly => 'Once a month',
    QazaFrequency.yearly => 'Once a year',
    QazaFrequency.custom => 'Custom days',
  };

  static QazaFrequency? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in QazaFrequency.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

/// One prayer's missed-prayer estimate (years/months/days since Bulugh)
/// plus how the user wants to be reminded to make it up.
class QazaPrayerBacklog {
  const QazaPrayerBacklog({
    this.days = 0,
    this.months = 0,
    this.years = 0,
    this.frequency,
  });

  final int days;
  final int months;
  final int years;
  final QazaFrequency? frequency;

  /// Total missed instances of *this single prayer* — unlike the old
  /// combined estimate, no ×5 multiplier: one Fajr is missed per day, not five.
  int get totalDays => years * 365 + months * 30 + days;

  QazaPrayerBacklog copyWith({
    int? days,
    int? months,
    int? years,
    QazaFrequency? frequency,
  }) {
    return QazaPrayerBacklog(
      days: days ?? this.days,
      months: months ?? this.months,
      years: years ?? this.years,
      frequency: frequency ?? this.frequency,
    );
  }

  Map<String, dynamic> toJson() => {
    'days': days,
    'months': months,
    'years': years,
    if (frequency != null) 'frequency': frequency!.firestoreValue,
  };

  static QazaPrayerBacklog fromRaw(Map? raw) {
    if (raw == null) return const QazaPrayerBacklog();
    return QazaPrayerBacklog(
      days: (raw['days'] as num?)?.toInt() ?? 0,
      months: (raw['months'] as num?)?.toInt() ?? 0,
      years: (raw['years'] as num?)?.toInt() ?? 0,
      frequency: QazaFrequencyX.fromFirestore(raw['frequency'] as String?),
    );
  }
}

/// `users/{uid}.qazaPlan` — per-prayer Qaza backlog + reminder frequency.
/// `setupComplete` distinguishes "never set up" (show the wizard) from
/// "set up, all zeros" (show the dashboard with nothing owed).
class QazaPlanParsed {
  const QazaPlanParsed({required this.setupComplete, required this.backlogs});

  final bool setupComplete;
  final Map<PrayerName, QazaPrayerBacklog> backlogs;

  QazaPrayerBacklog backlogFor(PrayerName name) =>
      backlogs[name] ?? const QazaPrayerBacklog();

  static QazaPlanParsed defaults() => QazaPlanParsed(
    setupComplete: false,
    backlogs: {for (final n in kQazaPrayerNames) n: const QazaPrayerBacklog()},
  );

  static QazaPlanParsed fromRaw(Map<String, dynamic>? raw) {
    if (raw == null) return defaults();
    final prayersRaw = raw['prayers'] as Map? ?? const {};
    final backlogs = <PrayerName, QazaPrayerBacklog>{};
    for (final n in kQazaPrayerNames) {
      backlogs[n] = QazaPrayerBacklog.fromRaw(prayersRaw[n.name] as Map?);
    }
    return QazaPlanParsed(
      setupComplete: raw['setupComplete'] as bool? ?? false,
      backlogs: backlogs,
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
    'setupComplete': setupComplete,
    'prayers': {for (final e in backlogs.entries) e.key.name: e.value.toJson()},
  };

  QazaPlanParsed copyWith({
    bool? setupComplete,
    Map<PrayerName, QazaPrayerBacklog>? backlogs,
  }) {
    return QazaPlanParsed(
      setupComplete: setupComplete ?? this.setupComplete,
      backlogs: backlogs ?? this.backlogs,
    );
  }
}
