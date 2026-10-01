// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrayerLog {

 String get dateKey; PrayerName get prayerName; PrayerType get type;/// Fard/Nawafil only; absent for Qaza logs.
@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) PrayerStatus? get status;/// Qaza only: how many make-ups this log counts (0..50, D-075/07 §2
/// `validLog`). `0` for Fard/Nawafil logs.
 int get count;/// Fard only, optional "prayed with Jama'at" flag — not yet shown in the
/// UI, reserved for future stats (09 §3.2).
 bool? get inJamaat;/// uid of whoever wrote this log: the subject themself, a guardian or a
/// teacher (07 `validLog` requires `markedBy == auth.uid`).
 String get markedBy;// `unknownEnumValue` needs a nullable field, and `source` is always
// written by this same client version — safe to require for now.
// Revisit once the app has real users and old-version compatibility
// matters (03 §4).
 PrayerLogSource get source; DateTime get markedAt;/// Kept for compatibility with the current app's "UTC of window start"
/// queries; [dateKey] is the source of truth for new code (09 §2).
 DateTime get dateTime;
/// Create a copy of PrayerLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerLogCopyWith<PrayerLog> get copyWith => _$PrayerLogCopyWithImpl<PrayerLog>(this as PrayerLog, _$identity);

  /// Serializes this PrayerLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerLog&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.prayerName, prayerName) || other.prayerName == prayerName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.inJamaat, inJamaat) || other.inJamaat == inJamaat)&&(identical(other.markedBy, markedBy) || other.markedBy == markedBy)&&(identical(other.source, source) || other.source == source)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,prayerName,type,status,count,inJamaat,markedBy,source,markedAt,dateTime);

@override
String toString() {
  return 'PrayerLog(dateKey: $dateKey, prayerName: $prayerName, type: $type, status: $status, count: $count, inJamaat: $inJamaat, markedBy: $markedBy, source: $source, markedAt: $markedAt, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $PrayerLogCopyWith<$Res>  {
  factory $PrayerLogCopyWith(PrayerLog value, $Res Function(PrayerLog) _then) = _$PrayerLogCopyWithImpl;
@useResult
$Res call({
 String dateKey, PrayerName prayerName, PrayerType type,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) PrayerStatus? status, int count, bool? inJamaat, String markedBy, PrayerLogSource source, DateTime markedAt, DateTime dateTime
});




}
/// @nodoc
class _$PrayerLogCopyWithImpl<$Res>
    implements $PrayerLogCopyWith<$Res> {
  _$PrayerLogCopyWithImpl(this._self, this._then);

  final PrayerLog _self;
  final $Res Function(PrayerLog) _then;

/// Create a copy of PrayerLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? prayerName = null,Object? type = null,Object? status = freezed,Object? count = null,Object? inJamaat = freezed,Object? markedBy = null,Object? source = null,Object? markedAt = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,prayerName: null == prayerName ? _self.prayerName : prayerName // ignore: cast_nullable_to_non_nullable
as PrayerName,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PrayerType,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrayerStatus?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,inJamaat: freezed == inJamaat ? _self.inJamaat : inJamaat // ignore: cast_nullable_to_non_nullable
as bool?,markedBy: null == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PrayerLogSource,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrayerLog].
extension PrayerLogPatterns on PrayerLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerLog value)  $default,){
final _that = this;
switch (_that) {
case _PrayerLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerLog value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  PrayerName prayerName,  PrayerType type, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  PrayerStatus? status,  int count,  bool? inJamaat,  String markedBy,  PrayerLogSource source,  DateTime markedAt,  DateTime dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerLog() when $default != null:
return $default(_that.dateKey,_that.prayerName,_that.type,_that.status,_that.count,_that.inJamaat,_that.markedBy,_that.source,_that.markedAt,_that.dateTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  PrayerName prayerName,  PrayerType type, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  PrayerStatus? status,  int count,  bool? inJamaat,  String markedBy,  PrayerLogSource source,  DateTime markedAt,  DateTime dateTime)  $default,) {final _that = this;
switch (_that) {
case _PrayerLog():
return $default(_that.dateKey,_that.prayerName,_that.type,_that.status,_that.count,_that.inJamaat,_that.markedBy,_that.source,_that.markedAt,_that.dateTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  PrayerName prayerName,  PrayerType type, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  PrayerStatus? status,  int count,  bool? inJamaat,  String markedBy,  PrayerLogSource source,  DateTime markedAt,  DateTime dateTime)?  $default,) {final _that = this;
switch (_that) {
case _PrayerLog() when $default != null:
return $default(_that.dateKey,_that.prayerName,_that.type,_that.status,_that.count,_that.inJamaat,_that.markedBy,_that.source,_that.markedAt,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrayerLog extends PrayerLog {
  const _PrayerLog({required this.dateKey, required this.prayerName, required this.type, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.status, this.count = 0, this.inJamaat, required this.markedBy, required this.source, required this.markedAt, required this.dateTime}): super._();
  factory _PrayerLog.fromJson(Map<String, dynamic> json) => _$PrayerLogFromJson(json);

@override final  String dateKey;
@override final  PrayerName prayerName;
@override final  PrayerType type;
/// Fard/Nawafil only; absent for Qaza logs.
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  PrayerStatus? status;
/// Qaza only: how many make-ups this log counts (0..50, D-075/07 §2
/// `validLog`). `0` for Fard/Nawafil logs.
@override@JsonKey() final  int count;
/// Fard only, optional "prayed with Jama'at" flag — not yet shown in the
/// UI, reserved for future stats (09 §3.2).
@override final  bool? inJamaat;
/// uid of whoever wrote this log: the subject themself, a guardian or a
/// teacher (07 `validLog` requires `markedBy == auth.uid`).
@override final  String markedBy;
// `unknownEnumValue` needs a nullable field, and `source` is always
// written by this same client version — safe to require for now.
// Revisit once the app has real users and old-version compatibility
// matters (03 §4).
@override final  PrayerLogSource source;
@override final  DateTime markedAt;
/// Kept for compatibility with the current app's "UTC of window start"
/// queries; [dateKey] is the source of truth for new code (09 §2).
@override final  DateTime dateTime;

/// Create a copy of PrayerLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerLogCopyWith<_PrayerLog> get copyWith => __$PrayerLogCopyWithImpl<_PrayerLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrayerLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerLog&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.prayerName, prayerName) || other.prayerName == prayerName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.inJamaat, inJamaat) || other.inJamaat == inJamaat)&&(identical(other.markedBy, markedBy) || other.markedBy == markedBy)&&(identical(other.source, source) || other.source == source)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,prayerName,type,status,count,inJamaat,markedBy,source,markedAt,dateTime);

@override
String toString() {
  return 'PrayerLog(dateKey: $dateKey, prayerName: $prayerName, type: $type, status: $status, count: $count, inJamaat: $inJamaat, markedBy: $markedBy, source: $source, markedAt: $markedAt, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$PrayerLogCopyWith<$Res> implements $PrayerLogCopyWith<$Res> {
  factory _$PrayerLogCopyWith(_PrayerLog value, $Res Function(_PrayerLog) _then) = __$PrayerLogCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, PrayerName prayerName, PrayerType type,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) PrayerStatus? status, int count, bool? inJamaat, String markedBy, PrayerLogSource source, DateTime markedAt, DateTime dateTime
});




}
/// @nodoc
class __$PrayerLogCopyWithImpl<$Res>
    implements _$PrayerLogCopyWith<$Res> {
  __$PrayerLogCopyWithImpl(this._self, this._then);

  final _PrayerLog _self;
  final $Res Function(_PrayerLog) _then;

/// Create a copy of PrayerLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? prayerName = null,Object? type = null,Object? status = freezed,Object? count = null,Object? inJamaat = freezed,Object? markedBy = null,Object? source = null,Object? markedAt = null,Object? dateTime = null,}) {
  return _then(_PrayerLog(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,prayerName: null == prayerName ? _self.prayerName : prayerName // ignore: cast_nullable_to_non_nullable
as PrayerName,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PrayerType,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrayerStatus?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,inJamaat: freezed == inJamaat ? _self.inJamaat : inJamaat // ignore: cast_nullable_to_non_nullable
as bool?,markedBy: null == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PrayerLogSource,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
