// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qaza_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QazaPrayerStat _$QazaPrayerStatFromJson(Map<String, dynamic> json) =>
    _QazaPrayerStat(
      estimate: (json['estimate'] as num?)?.toInt() ?? 0,
      trackedMissed: (json['trackedMissed'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QazaPrayerStatToJson(_QazaPrayerStat instance) =>
    <String, dynamic>{
      'estimate': instance.estimate,
      'trackedMissed': instance.trackedMissed,
      'completed': instance.completed,
      'remaining': instance.remaining,
    };

_QazaStats _$QazaStatsFromJson(Map<String, dynamic> json) => _QazaStats(
  perPrayer:
      (json['perPrayer'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, QazaPrayerStat.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  totalRemaining: (json['totalRemaining'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$QazaStatsToJson(_QazaStats instance) =>
    <String, dynamic>{
      'perPrayer': instance.perPrayer.map((k, e) => MapEntry(k, e.toJson())),
      'totalRemaining': instance.totalRemaining,
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };
