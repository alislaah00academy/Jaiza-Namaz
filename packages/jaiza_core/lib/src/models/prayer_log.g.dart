// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrayerLog _$PrayerLogFromJson(Map<String, dynamic> json) => _PrayerLog(
  dateKey: json['dateKey'] as String,
  prayerName: $enumDecode(_$PrayerNameEnumMap, json['prayerName']),
  type: $enumDecode(_$PrayerTypeEnumMap, json['type']),
  status: $enumDecodeNullable(
    _$PrayerStatusEnumMap,
    json['status'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  count: (json['count'] as num?)?.toInt() ?? 0,
  inJamaat: json['inJamaat'] as bool?,
  markedBy: json['markedBy'] as String,
  source: $enumDecode(_$PrayerLogSourceEnumMap, json['source']),
  markedAt: DateTime.parse(json['markedAt'] as String),
  dateTime: DateTime.parse(json['dateTime'] as String),
);

Map<String, dynamic> _$PrayerLogToJson(_PrayerLog instance) =>
    <String, dynamic>{
      'dateKey': instance.dateKey,
      'prayerName': _$PrayerNameEnumMap[instance.prayerName]!,
      'type': _$PrayerTypeEnumMap[instance.type]!,
      'status': ?_$PrayerStatusEnumMap[instance.status],
      'count': instance.count,
      'inJamaat': ?instance.inJamaat,
      'markedBy': instance.markedBy,
      'source': _$PrayerLogSourceEnumMap[instance.source]!,
      'markedAt': instance.markedAt.toIso8601String(),
      'dateTime': instance.dateTime.toIso8601String(),
    };

const _$PrayerNameEnumMap = {
  PrayerName.fajr: 'fajr',
  PrayerName.zuhr: 'zuhr',
  PrayerName.asr: 'asr',
  PrayerName.maghrib: 'maghrib',
  PrayerName.isha: 'isha',
  PrayerName.witr: 'witr',
  PrayerName.tahajjud: 'tahajjud',
  PrayerName.ishraq: 'ishraq',
  PrayerName.chasht: 'chasht',
  PrayerName.awwabin: 'awwabin',
  PrayerName.rawatib: 'rawatib',
  PrayerName.taraweeh: 'taraweeh',
  PrayerName.qazaGeneric: 'qazaGeneric',
};

const _$PrayerTypeEnumMap = {
  PrayerType.fard: 'fard',
  PrayerType.nawafil: 'nawafil',
  PrayerType.qaza: 'qaza',
};

const _$PrayerStatusEnumMap = {
  PrayerStatus.completed: 'completed',
  PrayerStatus.missed: 'missed',
};

const _$PrayerLogSourceEnumMap = {
  PrayerLogSource.app: 'app',
  PrayerLogSource.widget: 'widget',
  PrayerLogSource.teacher: 'teacher',
  PrayerLogSource.guardian: 'guardian',
};
