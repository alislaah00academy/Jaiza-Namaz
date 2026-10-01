// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelfSubject _$SelfSubjectFromJson(Map<String, dynamic> json) =>
    SelfSubject(json['uid'] as String, $type: json['kind'] as String?);

Map<String, dynamic> _$SelfSubjectToJson(SelfSubject instance) =>
    <String, dynamic>{'uid': instance.uid, 'kind': instance.$type};

ChildSubject _$ChildSubjectFromJson(Map<String, dynamic> json) =>
    ChildSubject(json['childId'] as String, $type: json['kind'] as String?);

Map<String, dynamic> _$ChildSubjectToJson(ChildSubject instance) =>
    <String, dynamic>{'childId': instance.childId, 'kind': instance.$type};

StudentSubject _$StudentSubjectFromJson(Map<String, dynamic> json) =>
    StudentSubject(json['studentId'] as String, $type: json['kind'] as String?);

Map<String, dynamic> _$StudentSubjectToJson(StudentSubject instance) =>
    <String, dynamic>{'studentId': instance.studentId, 'kind': instance.$type};
