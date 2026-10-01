// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakStats _$StreakStatsFromJson(Map<String, dynamic> json) => _StreakStats(
  current: (json['current'] as num?)?.toInt() ?? 0,
  longest: (json['longest'] as num?)?.toInt() ?? 0,
  lastPerfectDateKey: json['lastPerfectDateKey'] as String?,
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  nawafilTotal: (json['nawafilTotal'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StreakStatsToJson(_StreakStats instance) =>
    <String, dynamic>{
      'current': instance.current,
      'longest': instance.longest,
      'lastPerfectDateKey': ?instance.lastPerfectDateKey,
      'badges': instance.badges,
      'nawafilTotal': instance.nawafilTotal,
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };
