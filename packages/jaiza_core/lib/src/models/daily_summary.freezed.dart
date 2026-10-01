// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailySummary {

 String get dateKey; int get fardDone; int get fardMissed; int get fardUnmarked;/// Keyed by [PrayerName.name] (`fajr`…`isha`); value is `null` when that
/// prayer isn't marked yet. (`unknownEnumValue` isn't supported on a Map
/// value by json_serializable — Functions only ever write `completed`/
/// `missed`/absent, so this is safe.)
 Map<String, PrayerStatus?> get fard; int get nawafilDone; int get qazaDone;/// All 5 Fard `completed` for this [dateKey] (09 §5 "perfect day").
 bool get perfect; DateTime? get updatedAt;
/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySummaryCopyWith<DailySummary> get copyWith => _$DailySummaryCopyWithImpl<DailySummary>(this as DailySummary, _$identity);

  /// Serializes this DailySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySummary&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.fardDone, fardDone) || other.fardDone == fardDone)&&(identical(other.fardMissed, fardMissed) || other.fardMissed == fardMissed)&&(identical(other.fardUnmarked, fardUnmarked) || other.fardUnmarked == fardUnmarked)&&const DeepCollectionEquality().equals(other.fard, fard)&&(identical(other.nawafilDone, nawafilDone) || other.nawafilDone == nawafilDone)&&(identical(other.qazaDone, qazaDone) || other.qazaDone == qazaDone)&&(identical(other.perfect, perfect) || other.perfect == perfect)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,fardDone,fardMissed,fardUnmarked,const DeepCollectionEquality().hash(fard),nawafilDone,qazaDone,perfect,updatedAt);

@override
String toString() {
  return 'DailySummary(dateKey: $dateKey, fardDone: $fardDone, fardMissed: $fardMissed, fardUnmarked: $fardUnmarked, fard: $fard, nawafilDone: $nawafilDone, qazaDone: $qazaDone, perfect: $perfect, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DailySummaryCopyWith<$Res>  {
  factory $DailySummaryCopyWith(DailySummary value, $Res Function(DailySummary) _then) = _$DailySummaryCopyWithImpl;
@useResult
$Res call({
 String dateKey, int fardDone, int fardMissed, int fardUnmarked, Map<String, PrayerStatus?> fard, int nawafilDone, int qazaDone, bool perfect, DateTime? updatedAt
});




}
/// @nodoc
class _$DailySummaryCopyWithImpl<$Res>
    implements $DailySummaryCopyWith<$Res> {
  _$DailySummaryCopyWithImpl(this._self, this._then);

  final DailySummary _self;
  final $Res Function(DailySummary) _then;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? fardDone = null,Object? fardMissed = null,Object? fardUnmarked = null,Object? fard = null,Object? nawafilDone = null,Object? qazaDone = null,Object? perfect = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,fardDone: null == fardDone ? _self.fardDone : fardDone // ignore: cast_nullable_to_non_nullable
as int,fardMissed: null == fardMissed ? _self.fardMissed : fardMissed // ignore: cast_nullable_to_non_nullable
as int,fardUnmarked: null == fardUnmarked ? _self.fardUnmarked : fardUnmarked // ignore: cast_nullable_to_non_nullable
as int,fard: null == fard ? _self.fard : fard // ignore: cast_nullable_to_non_nullable
as Map<String, PrayerStatus?>,nawafilDone: null == nawafilDone ? _self.nawafilDone : nawafilDone // ignore: cast_nullable_to_non_nullable
as int,qazaDone: null == qazaDone ? _self.qazaDone : qazaDone // ignore: cast_nullable_to_non_nullable
as int,perfect: null == perfect ? _self.perfect : perfect // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySummary].
extension DailySummaryPatterns on DailySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySummary value)  $default,){
final _that = this;
switch (_that) {
case _DailySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  int fardDone,  int fardMissed,  int fardUnmarked,  Map<String, PrayerStatus?> fard,  int nawafilDone,  int qazaDone,  bool perfect,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
return $default(_that.dateKey,_that.fardDone,_that.fardMissed,_that.fardUnmarked,_that.fard,_that.nawafilDone,_that.qazaDone,_that.perfect,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  int fardDone,  int fardMissed,  int fardUnmarked,  Map<String, PrayerStatus?> fard,  int nawafilDone,  int qazaDone,  bool perfect,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DailySummary():
return $default(_that.dateKey,_that.fardDone,_that.fardMissed,_that.fardUnmarked,_that.fard,_that.nawafilDone,_that.qazaDone,_that.perfect,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  int fardDone,  int fardMissed,  int fardUnmarked,  Map<String, PrayerStatus?> fard,  int nawafilDone,  int qazaDone,  bool perfect,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DailySummary() when $default != null:
return $default(_that.dateKey,_that.fardDone,_that.fardMissed,_that.fardUnmarked,_that.fard,_that.nawafilDone,_that.qazaDone,_that.perfect,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailySummary implements DailySummary {
  const _DailySummary({required this.dateKey, this.fardDone = 0, this.fardMissed = 0, this.fardUnmarked = 0, final  Map<String, PrayerStatus?> fard = const {}, this.nawafilDone = 0, this.qazaDone = 0, this.perfect = false, this.updatedAt}): _fard = fard;
  factory _DailySummary.fromJson(Map<String, dynamic> json) => _$DailySummaryFromJson(json);

@override final  String dateKey;
@override@JsonKey() final  int fardDone;
@override@JsonKey() final  int fardMissed;
@override@JsonKey() final  int fardUnmarked;
/// Keyed by [PrayerName.name] (`fajr`…`isha`); value is `null` when that
/// prayer isn't marked yet. (`unknownEnumValue` isn't supported on a Map
/// value by json_serializable — Functions only ever write `completed`/
/// `missed`/absent, so this is safe.)
 final  Map<String, PrayerStatus?> _fard;
/// Keyed by [PrayerName.name] (`fajr`…`isha`); value is `null` when that
/// prayer isn't marked yet. (`unknownEnumValue` isn't supported on a Map
/// value by json_serializable — Functions only ever write `completed`/
/// `missed`/absent, so this is safe.)
@override@JsonKey() Map<String, PrayerStatus?> get fard {
  if (_fard is EqualUnmodifiableMapView) return _fard;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fard);
}

@override@JsonKey() final  int nawafilDone;
@override@JsonKey() final  int qazaDone;
/// All 5 Fard `completed` for this [dateKey] (09 §5 "perfect day").
@override@JsonKey() final  bool perfect;
@override final  DateTime? updatedAt;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySummaryCopyWith<_DailySummary> get copyWith => __$DailySummaryCopyWithImpl<_DailySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySummary&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.fardDone, fardDone) || other.fardDone == fardDone)&&(identical(other.fardMissed, fardMissed) || other.fardMissed == fardMissed)&&(identical(other.fardUnmarked, fardUnmarked) || other.fardUnmarked == fardUnmarked)&&const DeepCollectionEquality().equals(other._fard, _fard)&&(identical(other.nawafilDone, nawafilDone) || other.nawafilDone == nawafilDone)&&(identical(other.qazaDone, qazaDone) || other.qazaDone == qazaDone)&&(identical(other.perfect, perfect) || other.perfect == perfect)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,fardDone,fardMissed,fardUnmarked,const DeepCollectionEquality().hash(_fard),nawafilDone,qazaDone,perfect,updatedAt);

@override
String toString() {
  return 'DailySummary(dateKey: $dateKey, fardDone: $fardDone, fardMissed: $fardMissed, fardUnmarked: $fardUnmarked, fard: $fard, nawafilDone: $nawafilDone, qazaDone: $qazaDone, perfect: $perfect, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DailySummaryCopyWith<$Res> implements $DailySummaryCopyWith<$Res> {
  factory _$DailySummaryCopyWith(_DailySummary value, $Res Function(_DailySummary) _then) = __$DailySummaryCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, int fardDone, int fardMissed, int fardUnmarked, Map<String, PrayerStatus?> fard, int nawafilDone, int qazaDone, bool perfect, DateTime? updatedAt
});




}
/// @nodoc
class __$DailySummaryCopyWithImpl<$Res>
    implements _$DailySummaryCopyWith<$Res> {
  __$DailySummaryCopyWithImpl(this._self, this._then);

  final _DailySummary _self;
  final $Res Function(_DailySummary) _then;

/// Create a copy of DailySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? fardDone = null,Object? fardMissed = null,Object? fardUnmarked = null,Object? fard = null,Object? nawafilDone = null,Object? qazaDone = null,Object? perfect = null,Object? updatedAt = freezed,}) {
  return _then(_DailySummary(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,fardDone: null == fardDone ? _self.fardDone : fardDone // ignore: cast_nullable_to_non_nullable
as int,fardMissed: null == fardMissed ? _self.fardMissed : fardMissed // ignore: cast_nullable_to_non_nullable
as int,fardUnmarked: null == fardUnmarked ? _self.fardUnmarked : fardUnmarked // ignore: cast_nullable_to_non_nullable
as int,fard: null == fard ? _self._fard : fard // ignore: cast_nullable_to_non_nullable
as Map<String, PrayerStatus?>,nawafilDone: null == nawafilDone ? _self.nawafilDone : nawafilDone // ignore: cast_nullable_to_non_nullable
as int,qazaDone: null == qazaDone ? _self.qazaDone : qazaDone // ignore: cast_nullable_to_non_nullable
as int,perfect: null == perfect ? _self.perfect : perfect // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
