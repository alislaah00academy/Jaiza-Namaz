// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakStats {

 int get current; int get longest; String? get lastPerfectDateKey;/// Badge ids from `kBadgeDefinitions`, e.g. `first_step`, `week_warrior`.
/// Never removed once earned.
 List<String> get badges; int get nawafilTotal; DateTime? get updatedAt;
/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakStatsCopyWith<StreakStats> get copyWith => _$StreakStatsCopyWithImpl<StreakStats>(this as StreakStats, _$identity);

  /// Serializes this StreakStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakStats&&(identical(other.current, current) || other.current == current)&&(identical(other.longest, longest) || other.longest == longest)&&(identical(other.lastPerfectDateKey, lastPerfectDateKey) || other.lastPerfectDateKey == lastPerfectDateKey)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.nawafilTotal, nawafilTotal) || other.nawafilTotal == nawafilTotal)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,longest,lastPerfectDateKey,const DeepCollectionEquality().hash(badges),nawafilTotal,updatedAt);

@override
String toString() {
  return 'StreakStats(current: $current, longest: $longest, lastPerfectDateKey: $lastPerfectDateKey, badges: $badges, nawafilTotal: $nawafilTotal, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StreakStatsCopyWith<$Res>  {
  factory $StreakStatsCopyWith(StreakStats value, $Res Function(StreakStats) _then) = _$StreakStatsCopyWithImpl;
@useResult
$Res call({
 int current, int longest, String? lastPerfectDateKey, List<String> badges, int nawafilTotal, DateTime? updatedAt
});




}
/// @nodoc
class _$StreakStatsCopyWithImpl<$Res>
    implements $StreakStatsCopyWith<$Res> {
  _$StreakStatsCopyWithImpl(this._self, this._then);

  final StreakStats _self;
  final $Res Function(StreakStats) _then;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? longest = null,Object? lastPerfectDateKey = freezed,Object? badges = null,Object? nawafilTotal = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,longest: null == longest ? _self.longest : longest // ignore: cast_nullable_to_non_nullable
as int,lastPerfectDateKey: freezed == lastPerfectDateKey ? _self.lastPerfectDateKey : lastPerfectDateKey // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,nawafilTotal: null == nawafilTotal ? _self.nawafilTotal : nawafilTotal // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakStats].
extension StreakStatsPatterns on StreakStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakStats value)  $default,){
final _that = this;
switch (_that) {
case _StreakStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakStats value)?  $default,){
final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int longest,  String? lastPerfectDateKey,  List<String> badges,  int nawafilTotal,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
return $default(_that.current,_that.longest,_that.lastPerfectDateKey,_that.badges,_that.nawafilTotal,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int longest,  String? lastPerfectDateKey,  List<String> badges,  int nawafilTotal,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StreakStats():
return $default(_that.current,_that.longest,_that.lastPerfectDateKey,_that.badges,_that.nawafilTotal,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int longest,  String? lastPerfectDateKey,  List<String> badges,  int nawafilTotal,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
return $default(_that.current,_that.longest,_that.lastPerfectDateKey,_that.badges,_that.nawafilTotal,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakStats implements StreakStats {
  const _StreakStats({this.current = 0, this.longest = 0, this.lastPerfectDateKey, final  List<String> badges = const <String>[], this.nawafilTotal = 0, this.updatedAt}): _badges = badges;
  factory _StreakStats.fromJson(Map<String, dynamic> json) => _$StreakStatsFromJson(json);

@override@JsonKey() final  int current;
@override@JsonKey() final  int longest;
@override final  String? lastPerfectDateKey;
/// Badge ids from `kBadgeDefinitions`, e.g. `first_step`, `week_warrior`.
/// Never removed once earned.
 final  List<String> _badges;
/// Badge ids from `kBadgeDefinitions`, e.g. `first_step`, `week_warrior`.
/// Never removed once earned.
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override@JsonKey() final  int nawafilTotal;
@override final  DateTime? updatedAt;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakStatsCopyWith<_StreakStats> get copyWith => __$StreakStatsCopyWithImpl<_StreakStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakStats&&(identical(other.current, current) || other.current == current)&&(identical(other.longest, longest) || other.longest == longest)&&(identical(other.lastPerfectDateKey, lastPerfectDateKey) || other.lastPerfectDateKey == lastPerfectDateKey)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.nawafilTotal, nawafilTotal) || other.nawafilTotal == nawafilTotal)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,longest,lastPerfectDateKey,const DeepCollectionEquality().hash(_badges),nawafilTotal,updatedAt);

@override
String toString() {
  return 'StreakStats(current: $current, longest: $longest, lastPerfectDateKey: $lastPerfectDateKey, badges: $badges, nawafilTotal: $nawafilTotal, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StreakStatsCopyWith<$Res> implements $StreakStatsCopyWith<$Res> {
  factory _$StreakStatsCopyWith(_StreakStats value, $Res Function(_StreakStats) _then) = __$StreakStatsCopyWithImpl;
@override @useResult
$Res call({
 int current, int longest, String? lastPerfectDateKey, List<String> badges, int nawafilTotal, DateTime? updatedAt
});




}
/// @nodoc
class __$StreakStatsCopyWithImpl<$Res>
    implements _$StreakStatsCopyWith<$Res> {
  __$StreakStatsCopyWithImpl(this._self, this._then);

  final _StreakStats _self;
  final $Res Function(_StreakStats) _then;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? longest = null,Object? lastPerfectDateKey = freezed,Object? badges = null,Object? nawafilTotal = null,Object? updatedAt = freezed,}) {
  return _then(_StreakStats(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,longest: null == longest ? _self.longest : longest // ignore: cast_nullable_to_non_nullable
as int,lastPerfectDateKey: freezed == lastPerfectDateKey ? _self.lastPerfectDateKey : lastPerfectDateKey // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,nawafilTotal: null == nawafilTotal ? _self.nawafilTotal : nawafilTotal // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
