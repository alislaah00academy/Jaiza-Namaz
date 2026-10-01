import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject_ref.freezed.dart';
part 'subject_ref.g.dart';

/// Whose prayers a screen or provider is about (04 §4). Every
/// prayer/streak/qaza provider takes one, so Individual, Parent and Teacher
/// screens share one implementation.
@Freezed(unionKey: 'kind')
sealed class SubjectRef with _$SubjectRef {
  const SubjectRef._();

  /// The signed-in user.
  const factory SubjectRef.self(String uid) = SelfSubject;

  /// A child managed by the signed-in guardian (`children/{id}`).
  const factory SubjectRef.child(String childId) = ChildSubject;

  /// A madrasa student (`students/{id}`).
  const factory SubjectRef.student(String studentId) = StudentSubject;

  factory SubjectRef.fromJson(Map<String, dynamic> json) =>
      _$SubjectRefFromJson(json);

  /// The subject's document path: `users/{uid}`, `children/{id}` or
  /// `students/{id}`.
  String get documentPath => switch (this) {
    SelfSubject(:final uid) => 'users/$uid',
    ChildSubject(:final childId) => 'children/$childId',
    StudentSubject(:final studentId) => 'students/$studentId',
  };

  /// `{subject}/prayers` (D-072).
  String get prayersPath => '$documentPath/prayers';

  /// `{subject}/dailySummaries` (06 §2.3).
  String get dailySummariesPath => '$documentPath/dailySummaries';
}
