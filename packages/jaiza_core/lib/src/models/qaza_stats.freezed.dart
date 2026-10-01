// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qaza_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QazaPrayerStat {

/// From the user's own estimate wizard (years/months/days since
/// puberty), per prayer — not ×5 (09 §4.1).
 int get estimate;/// Fard windows since `trackingSince` that ended `missed` or unmarked.
 int get trackedMissed;/// Sum of `count` on this prayer's Qaza logs.
 int get completed; int get remaining;
/// Create a copy of QazaPrayerStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QazaPrayerStatCopyWith<QazaPrayerStat> get copyWith => _$QazaPrayerStatCopyWithImpl<QazaPrayerStat>(this as QazaPrayerStat, _$identity);

  /// Serializes this QazaPrayerStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QazaPrayerStat&&(identical(other.estimate, estimate) || other.estimate == estimate)&&(identical(other.trackedMissed, trackedMissed) || other.trackedMissed == trackedMissed)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimate,trackedMissed,completed,remaining);

@override
String toString() {
  return 'QazaPrayerStat(estimate: $estimate, trackedMissed: $trackedMissed, completed: $completed, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $QazaPrayerStatCopyWith<$Res>  {
  factory $QazaPrayerStatCopyWith(QazaPrayerStat value, $Res Function(QazaPrayerStat) _then) = _$QazaPrayerStatCopyWithImpl;
@useResult
$Res call({
 int estimate, int trackedMissed, int completed, int remaining
});




}
/// @nodoc
class _$QazaPrayerStatCopyWithImpl<$Res>
    implements $QazaPrayerStatCopyWith<$Res> {
  _$QazaPrayerStatCopyWithImpl(this._self, this._then);

  final QazaPrayerStat _self;
  final $Res Function(QazaPrayerStat) _then;

/// Create a copy of QazaPrayerStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? estimate = null,Object? trackedMissed = null,Object? completed = null,Object? remaining = null,}) {
  return _then(_self.copyWith(
estimate: null == estimate ? _self.estimate : estimate // ignore: cast_nullable_to_non_nullable
as int,trackedMissed: null == trackedMissed ? _self.trackedMissed : trackedMissed // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QazaPrayerStat].
extension QazaPrayerStatPatterns on QazaPrayerStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QazaPrayerStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QazaPrayerStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QazaPrayerStat value)  $default,){
final _that = this;
switch (_that) {
case _QazaPrayerStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QazaPrayerStat value)?  $default,){
final _that = this;
switch (_that) {
case _QazaPrayerStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int estimate,  int trackedMissed,  int completed,  int remaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QazaPrayerStat() when $default != null:
return $default(_that.estimate,_that.trackedMissed,_that.completed,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int estimate,  int trackedMissed,  int completed,  int remaining)  $default,) {final _that = this;
switch (_that) {
case _QazaPrayerStat():
return $default(_that.estimate,_that.trackedMissed,_that.completed,_that.remaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int estimate,  int trackedMissed,  int completed,  int remaining)?  $default,) {final _that = this;
switch (_that) {
case _QazaPrayerStat() when $default != null:
return $default(_that.estimate,_that.trackedMissed,_that.completed,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QazaPrayerStat extends QazaPrayerStat {
  const _QazaPrayerStat({this.estimate = 0, this.trackedMissed = 0, this.completed = 0, this.remaining = 0}): super._();
  factory _QazaPrayerStat.fromJson(Map<String, dynamic> json) => _$QazaPrayerStatFromJson(json);

/// From the user's own estimate wizard (years/months/days since
/// puberty), per prayer — not ×5 (09 §4.1).
@override@JsonKey() final  int estimate;
/// Fard windows since `trackingSince` that ended `missed` or unmarked.
@override@JsonKey() final  int trackedMissed;
/// Sum of `count` on this prayer's Qaza logs.
@override@JsonKey() final  int completed;
@override@JsonKey() final  int remaining;

/// Create a copy of QazaPrayerStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QazaPrayerStatCopyWith<_QazaPrayerStat> get copyWith => __$QazaPrayerStatCopyWithImpl<_QazaPrayerStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QazaPrayerStatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QazaPrayerStat&&(identical(other.estimate, estimate) || other.estimate == estimate)&&(identical(other.trackedMissed, trackedMissed) || other.trackedMissed == trackedMissed)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimate,trackedMissed,completed,remaining);

@override
String toString() {
  return 'QazaPrayerStat(estimate: $estimate, trackedMissed: $trackedMissed, completed: $completed, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class _$QazaPrayerStatCopyWith<$Res> implements $QazaPrayerStatCopyWith<$Res> {
  factory _$QazaPrayerStatCopyWith(_QazaPrayerStat value, $Res Function(_QazaPrayerStat) _then) = __$QazaPrayerStatCopyWithImpl;
@override @useResult
$Res call({
 int estimate, int trackedMissed, int completed, int remaining
});




}
/// @nodoc
class __$QazaPrayerStatCopyWithImpl<$Res>
    implements _$QazaPrayerStatCopyWith<$Res> {
  __$QazaPrayerStatCopyWithImpl(this._self, this._then);

  final _QazaPrayerStat _self;
  final $Res Function(_QazaPrayerStat) _then;

/// Create a copy of QazaPrayerStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? estimate = null,Object? trackedMissed = null,Object? completed = null,Object? remaining = null,}) {
  return _then(_QazaPrayerStat(
estimate: null == estimate ? _self.estimate : estimate // ignore: cast_nullable_to_non_nullable
as int,trackedMissed: null == trackedMissed ? _self.trackedMissed : trackedMissed // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$QazaStats {

/// Keyed by [PrayerName.name] for the 5 Fard prayers.
 Map<String, QazaPrayerStat> get perPrayer; int get totalRemaining; DateTime? get updatedAt;
/// Create a copy of QazaStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QazaStatsCopyWith<QazaStats> get copyWith => _$QazaStatsCopyWithImpl<QazaStats>(this as QazaStats, _$identity);

  /// Serializes this QazaStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QazaStats&&const DeepCollectionEquality().equals(other.perPrayer, perPrayer)&&(identical(other.totalRemaining, totalRemaining) || other.totalRemaining == totalRemaining)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(perPrayer),totalRemaining,updatedAt);

@override
String toString() {
  return 'QazaStats(perPrayer: $perPrayer, totalRemaining: $totalRemaining, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $QazaStatsCopyWith<$Res>  {
  factory $QazaStatsCopyWith(QazaStats value, $Res Function(QazaStats) _then) = _$QazaStatsCopyWithImpl;
@useResult
$Res call({
 Map<String, QazaPrayerStat> perPrayer, int totalRemaining, DateTime? updatedAt
});




}
/// @nodoc
class _$QazaStatsCopyWithImpl<$Res>
    implements $QazaStatsCopyWith<$Res> {
  _$QazaStatsCopyWithImpl(this._self, this._then);

  final QazaStats _self;
  final $Res Function(QazaStats) _then;

/// Create a copy of QazaStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? perPrayer = null,Object? totalRemaining = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
perPrayer: null == perPrayer ? _self.perPrayer : perPrayer // ignore: cast_nullable_to_non_nullable
as Map<String, QazaPrayerStat>,totalRemaining: null == totalRemaining ? _self.totalRemaining : totalRemaining // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [QazaStats].
extension QazaStatsPatterns on QazaStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QazaStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QazaStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QazaStats value)  $default,){
final _that = this;
switch (_that) {
case _QazaStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QazaStats value)?  $default,){
final _that = this;
switch (_that) {
case _QazaStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, QazaPrayerStat> perPrayer,  int totalRemaining,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QazaStats() when $default != null:
return $default(_that.perPrayer,_that.totalRemaining,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, QazaPrayerStat> perPrayer,  int totalRemaining,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _QazaStats():
return $default(_that.perPrayer,_that.totalRemaining,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, QazaPrayerStat> perPrayer,  int totalRemaining,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _QazaStats() when $default != null:
return $default(_that.perPrayer,_that.totalRemaining,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QazaStats implements QazaStats {
  const _QazaStats({final  Map<String, QazaPrayerStat> perPrayer = const {}, this.totalRemaining = 0, this.updatedAt}): _perPrayer = perPrayer;
  factory _QazaStats.fromJson(Map<String, dynamic> json) => _$QazaStatsFromJson(json);

/// Keyed by [PrayerName.name] for the 5 Fard prayers.
 final  Map<String, QazaPrayerStat> _perPrayer;
/// Keyed by [PrayerName.name] for the 5 Fard prayers.
@override@JsonKey() Map<String, QazaPrayerStat> get perPrayer {
  if (_perPrayer is EqualUnmodifiableMapView) return _perPrayer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perPrayer);
}

@override@JsonKey() final  int totalRemaining;
@override final  DateTime? updatedAt;

/// Create a copy of QazaStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QazaStatsCopyWith<_QazaStats> get copyWith => __$QazaStatsCopyWithImpl<_QazaStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QazaStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QazaStats&&const DeepCollectionEquality().equals(other._perPrayer, _perPrayer)&&(identical(other.totalRemaining, totalRemaining) || other.totalRemaining == totalRemaining)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_perPrayer),totalRemaining,updatedAt);

@override
String toString() {
  return 'QazaStats(perPrayer: $perPrayer, totalRemaining: $totalRemaining, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$QazaStatsCopyWith<$Res> implements $QazaStatsCopyWith<$Res> {
  factory _$QazaStatsCopyWith(_QazaStats value, $Res Function(_QazaStats) _then) = __$QazaStatsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, QazaPrayerStat> perPrayer, int totalRemaining, DateTime? updatedAt
});




}
/// @nodoc
class __$QazaStatsCopyWithImpl<$Res>
    implements _$QazaStatsCopyWith<$Res> {
  __$QazaStatsCopyWithImpl(this._self, this._then);

  final _QazaStats _self;
  final $Res Function(_QazaStats) _then;

/// Create a copy of QazaStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? perPrayer = null,Object? totalRemaining = null,Object? updatedAt = freezed,}) {
  return _then(_QazaStats(
perPrayer: null == perPrayer ? _self._perPrayer : perPrayer // ignore: cast_nullable_to_non_nullable
as Map<String, QazaPrayerStat>,totalRemaining: null == totalRemaining ? _self.totalRemaining : totalRemaining // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
