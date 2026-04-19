import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/logging/app_log.dart';
import '../models/app_user.dart';

/// Firestore user profile at `users/{uid}`.
class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(AppUser.fromSnapshot);
  }

  /// Creates / merges profile after registration (name + email + timestamps).
  Future<void> createUserProfile({
    required User user,
    required String name,
  }) async {
    try {
      await _users.doc(user.uid).set(
        {
          'uid': user.uid,
          'name': name.trim(),
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'nawafilEnabled': false,
          'qazaBacklogYears': 0,
          'qazaBacklogMonths': 0,
          'qazaBacklogDays': 0,
          'qazaDailyTarget': 1,
        },
        SetOptions(merge: true),
      );
    } catch (e, st) {
      appLog('createUserProfile', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Syncs auth fields on login without wiping extended fields.
  Future<void> syncFromAuth(User user) async {
    try {
      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final dn = user.displayName;
      if (dn != null && dn.isNotEmpty) {
        data['name'] = dn;
      }
      await _users.doc(user.uid).set(data, SetOptions(merge: true));
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
}
