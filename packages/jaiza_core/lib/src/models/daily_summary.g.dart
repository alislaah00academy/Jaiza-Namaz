// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailySummary _$DailySummaryFromJson(Map<String, dynamic> json) =>
    _DailySummary(
      dateKey: json['dateKey'] as String,
      fardDone: (json['fardDone'] as num?)?.toInt() ?? 0,
      fardMissed: (json['fardMissed'] as num?)?.toInt() ?? 0,
      fardUnmarked: (json['fardUnmarked'] as num?)?.toInt() ?? 0,
      fard:
          (json['fard'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, $enumDecodeNullable(_$PrayerStatusEnumMap, e)),
          ) ??
          const {},
      nawafilDone: (json['nawafilDone'] as num?)?.toInt() ?? 0,
      qazaDone: (json['qazaDone'] as num?)?.toInt() ?? 0,
      perfect: json['perfect'] as bool? ?? false,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DailySummaryToJson(
  _DailySummary instance,
) => <String, dynamic>{
  'dateKey': instance.dateKey,
  'fardDone': instance.fardDone,
  'fardMissed': instance.fardMissed,
  'fardUnmarked': instance.fardUnmarked,
  'fard': instance.fard.map((k, e) => MapEntry(k, _$PrayerStatusEnumMap[e])),
  'nawafilDone': instance.nawafilDone,
  'qazaDone': instance.qazaDone,
  'perfect': instance.perfect,
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

const _$PrayerStatusEnumMap = {
  PrayerStatus.completed: 'completed',
  PrayerStatus.missed: 'missed',
};
