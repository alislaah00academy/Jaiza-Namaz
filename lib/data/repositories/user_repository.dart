import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/logging/app_log.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// Firestore user profile at `users/{uid}`.
class UserRepository {
  UserRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(AppUser.fromSnapshot);
  }

  /// `ensureUserProfile` (08 §2.1): the server creates `users/{uid}` if it is
  /// missing and refreshes name/lastSeenAt. Clients can't create or write
  /// `uid/email/createdAt/modes/...` themselves (07 `users` rule).
  Future<void> _ensureProfile({String? name}) async {
    final trimmed = name?.trim();
    await _functions.httpsCallable('ensureUserProfile').call<Object?>({
      if (trimmed != null && trimmed.isNotEmpty) 'name': trimmed,
    });
  }

  /// Creates the profile after registration (the server owns the document).
  Future<void> createUserProfile({
    required User user,
    required String name,
  }) async {
    try {
      await _ensureProfile(name: name);
    } catch (e, st) {
      appLog('createUserProfile', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Refreshes the profile on login without wiping extended fields.
  Future<void> syncFromAuth(User user) async {
    try {
      await _ensureProfile(name: user.displayName);
    } catch (e, st) {
      appLog('syncFromAuth', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    String? email,
    int? age,
    String? city,
    String? phone,
    bool? nawafilEnabled,
    int? qazaBacklogYears,
    int? qazaBacklogMonths,
    int? qazaBacklogDays,
    int? qazaDailyTarget,
  }) async {
    try {
      final map = <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (email != null) map['email'] = email;
      if (age != null) map['age'] = age;
      if (city != null) map['city'] = city;
      if (phone != null) map['phone'] = phone;
      if (nawafilEnabled != null) map['nawafilEnabled'] = nawafilEnabled;
      if (qazaBacklogYears != null) map['qazaBacklogYears'] = qazaBacklogYears;
      if (qazaBacklogMonths != null) {
        map['qazaBacklogMonths'] = qazaBacklogMonths;
      }
      if (qazaBacklogDays != null) map['qazaBacklogDays'] = qazaBacklogDays;
      if (qazaDailyTarget != null) map['qazaDailyTarget'] = qazaDailyTarget;
      await _users.doc(uid).set(map, SetOptions(merge: true));
    } catch (e, st) {
      appLog('updateProfile', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Sets the account type once, after the role-selection screen. Individual
  /// stays the implicit default for any account that never calls this.
  Future<void> setRole({
    required String uid,
    required UserRole role,
    String? orgId,
    OrgMemberRole? orgMemberRole,
  }) async {
    try {
      await _users.doc(uid).set({
        'role': role.firestoreValue,
        'orgId': ?orgId,
        'orgMemberRole': ?orgMemberRole?.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      appLog('setRole', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Attaches this account as a teacher of [orgId] (used when claiming a
  /// pending invite on login/signup).
  Future<void> attachAsOrgTeacher({
    required String uid,
    required String orgId,
  }) async {
    try {
      await _users.doc(uid).set({
        'role': UserRole.organization.firestoreValue,
        'orgId': orgId,
        'orgMemberRole': OrgMemberRole.teacher.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      appLog('attachAsOrgTeacher', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Merges `users/{uid}.prayerSettings` (widget + notification prefs).
  Future<void> updatePrayerSettings({
    required String uid,
    required Map<String, dynamic> prayerSettings,
  }) async {
    try {
      await _users.doc(uid).set({
        'prayerSettings': prayerSettings,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      appLog('updatePrayerSettings', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Merges `users/{uid}.qazaPlan` (per-prayer Qaza backlog + frequency).
  Future<void> updateQazaPlan({
    required String uid,
    required Map<String, dynamic> qazaPlan,
  }) async {
    try {
      await _users.doc(uid).set({
        'qazaPlan': qazaPlan,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      appLog('updateQazaPlan', error: e, stackTrace: st);
      rethrow;
    }
  }
}
