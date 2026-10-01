// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SubjectRef _$SubjectRefFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'self':
          return SelfSubject.fromJson(
            json
          );
                case 'child':
          return ChildSubject.fromJson(
            json
          );
                case 'student':
          return StudentSubject.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'SubjectRef',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$SubjectRef {



  /// Serializes this SubjectRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubjectRef);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubjectRef()';
}


}

/// @nodoc
class $SubjectRefCopyWith<$Res>  {
$SubjectRefCopyWith(SubjectRef _, $Res Function(SubjectRef) __);
}


/// Adds pattern-matching-related methods to [SubjectRef].
extension SubjectRefPatterns on SubjectRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SelfSubject value)?  self,TResult Function( ChildSubject value)?  child,TResult Function( StudentSubject value)?  student,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SelfSubject() when self != null:
return self(_that);case ChildSubject() when child != null:
return child(_that);case StudentSubject() when student != null:
return student(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SelfSubject value)  self,required TResult Function( ChildSubject value)  child,required TResult Function( StudentSubject value)  student,}){
final _that = this;
switch (_that) {
case SelfSubject():
return self(_that);case ChildSubject():
return child(_that);case StudentSubject():
return student(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SelfSubject value)?  self,TResult? Function( ChildSubject value)?  child,TResult? Function( StudentSubject value)?  student,}){
final _that = this;
switch (_that) {
case SelfSubject() when self != null:
return self(_that);case ChildSubject() when child != null:
return child(_that);case StudentSubject() when student != null:
return student(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uid)?  self,TResult Function( String childId)?  child,TResult Function( String studentId)?  student,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SelfSubject() when self != null:
return self(_that.uid);case ChildSubject() when child != null:
return child(_that.childId);case StudentSubject() when student != null:
return student(_that.studentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uid)  self,required TResult Function( String childId)  child,required TResult Function( String studentId)  student,}) {final _that = this;
switch (_that) {
case SelfSubject():
return self(_that.uid);case ChildSubject():
return child(_that.childId);case StudentSubject():
return student(_that.studentId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uid)?  self,TResult? Function( String childId)?  child,TResult? Function( String studentId)?  student,}) {final _that = this;
switch (_that) {
case SelfSubject() when self != null:
return self(_that.uid);case ChildSubject() when child != null:
return child(_that.childId);case StudentSubject() when student != null:
return student(_that.studentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SelfSubject extends SubjectRef {
  const SelfSubject(this.uid, {final  String? $type}): $type = $type ?? 'self',super._();
  factory SelfSubject.fromJson(Map<String, dynamic> json) => _$SelfSubjectFromJson(json);

 final  String uid;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelfSubjectCopyWith<SelfSubject> get copyWith => _$SelfSubjectCopyWithImpl<SelfSubject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelfSubjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelfSubject&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid);

@override
String toString() {
  return 'SubjectRef.self(uid: $uid)';
}


}

/// @nodoc
abstract mixin class $SelfSubjectCopyWith<$Res> implements $SubjectRefCopyWith<$Res> {
  factory $SelfSubjectCopyWith(SelfSubject value, $Res Function(SelfSubject) _then) = _$SelfSubjectCopyWithImpl;
@useResult
$Res call({
 String uid
});




}
/// @nodoc
class _$SelfSubjectCopyWithImpl<$Res>
    implements $SelfSubjectCopyWith<$Res> {
  _$SelfSubjectCopyWithImpl(this._self, this._then);

  final SelfSubject _self;
  final $Res Function(SelfSubject) _then;

/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uid = null,}) {
  return _then(SelfSubject(
null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChildSubject extends SubjectRef {
  const ChildSubject(this.childId, {final  String? $type}): $type = $type ?? 'child',super._();
  factory ChildSubject.fromJson(Map<String, dynamic> json) => _$ChildSubjectFromJson(json);

 final  String childId;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildSubjectCopyWith<ChildSubject> get copyWith => _$ChildSubjectCopyWithImpl<ChildSubject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildSubjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildSubject&&(identical(other.childId, childId) || other.childId == childId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,childId);

@override
String toString() {
  return 'SubjectRef.child(childId: $childId)';
}


}

/// @nodoc
abstract mixin class $ChildSubjectCopyWith<$Res> implements $SubjectRefCopyWith<$Res> {
  factory $ChildSubjectCopyWith(ChildSubject value, $Res Function(ChildSubject) _then) = _$ChildSubjectCopyWithImpl;
@useResult
$Res call({
 String childId
});




}
/// @nodoc
class _$ChildSubjectCopyWithImpl<$Res>
    implements $ChildSubjectCopyWith<$Res> {
  _$ChildSubjectCopyWithImpl(this._self, this._then);

  final ChildSubject _self;
  final $Res Function(ChildSubject) _then;

/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? childId = null,}) {
  return _then(ChildSubject(
null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class StudentSubject extends SubjectRef {
  const StudentSubject(this.studentId, {final  String? $type}): $type = $type ?? 'student',super._();
  factory StudentSubject.fromJson(Map<String, dynamic> json) => _$StudentSubjectFromJson(json);

 final  String studentId;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentSubjectCopyWith<StudentSubject> get copyWith => _$StudentSubjectCopyWithImpl<StudentSubject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentSubjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentSubject&&(identical(other.studentId, studentId) || other.studentId == studentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,studentId);

@override
String toString() {
  return 'SubjectRef.student(studentId: $studentId)';
}


}

/// @nodoc
abstract mixin class $StudentSubjectCopyWith<$Res> implements $SubjectRefCopyWith<$Res> {
  factory $StudentSubjectCopyWith(StudentSubject value, $Res Function(StudentSubject) _then) = _$StudentSubjectCopyWithImpl;
@useResult
$Res call({
 String studentId
});




}
/// @nodoc
class _$StudentSubjectCopyWithImpl<$Res>
    implements $StudentSubjectCopyWith<$Res> {
  _$StudentSubjectCopyWithImpl(this._self, this._then);

  final StudentSubject _self;
  final $Res Function(StudentSubject) _then;

/// Create a copy of SubjectRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? studentId = null,}) {
  return _then(StudentSubject(
null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
