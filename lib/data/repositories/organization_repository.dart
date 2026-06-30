import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/logging/app_log.dart';
import '../models/organization.dart';

/// Thrown by [OrganizationRepository.inviteTeacher] when re-inviting an
/// email that already has an active (claimed) teacher membership in this org.
class TeacherAlreadyActiveException implements Exception {
  const TeacherAlreadyActiveException();

  @override
  String toString() => 'This person is already a teacher here.';
}

/// A pending teacher invite found for some email, with enough context to
/// show a human-readable confirmation prompt before claiming it.
class PendingTeacherInvite {
  const PendingTeacherInvite({required this.orgId, required this.orgName});

  final String orgId;
  final String orgName;
}

/// `organizations/{orgId}` and its `invites`/`teachers`/`classes`/`students`
/// subcollections.
class OrganizationRepository {
  OrganizationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orgs =>
      _firestore.collection('organizations');

  CollectionReference<Map<String, dynamic>> _invites(String orgId) =>
      _orgs.doc(orgId).collection('invites');

  CollectionReference<Map<String, dynamic>> _teachers(String orgId) =>
      _orgs.doc(orgId).collection('teachers');

  CollectionReference<Map<String, dynamic>> _classes(String orgId) =>
      _orgs.doc(orgId).collection('classes');

  CollectionReference<Map<String, dynamic>> _students(
    String orgId,
    String classId,
  ) => _classes(orgId).doc(classId).collection('students');

  /// Creates a new organization owned by [adminUid]. Returns the new orgId.
  Future<String> createOrganization({
    required String adminUid,
    required String name,
  }) async {
    try {
      final doc = _orgs.doc();
      await doc.set({
        'name': name.trim(),
        'adminUid': adminUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e, st) {
      appLog('createOrganization', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<Organization?> watchOrganization(String orgId) {
    return _orgs.doc(orgId).snapshots().map(Organization.fromFirestore);
  }

  /// The org this uid administers, if any.
  Stream<Organization?> watchOrgForAdmin(String adminUid) {
    return _orgs
        .where('adminUid', isEqualTo: adminUid)
        .limit(1)
        .snapshots()
        .map(
          (snap) => snap.docs.isEmpty
              ? null
              : Organization.fromFirestore(snap.docs.first),
        );
  }

  /// Invites [email] as a teacher. Throws [TeacherAlreadyActiveException] if
  /// this email already claimed a teacher invite for this org — re-inviting
  /// an active teacher would otherwise silently reset their invite doc back
  /// to `pending` and wipe `claimedByUid`.
  Future<void> inviteTeacher({
    required String orgId,
    required String email,
  }) async {
    try {
      final emailLower = email.trim().toLowerCase();
      final existing = await _invites(orgId).doc(emailLower).get();
      final existingStatus = existing.data()?['status'] as String?;
      if (existingStatus == InviteStatus.claimed.firestoreValue) {
        throw const TeacherAlreadyActiveException();
      }
      await _invites(orgId).doc(emailLower).set({
        'email': emailLower,
        'role': 'teacher',
        'status': InviteStatus.pending.firestoreValue,
        'invitedAt': FieldValue.serverTimestamp(),
      });
    } on TeacherAlreadyActiveException {
      rethrow;
    } catch (e, st) {
      appLog('inviteTeacher', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Revokes a teacher's membership. Leaves `users/{teacherUid}.role`
  /// untouched — the teacher's own dashboard detects the missing membership
  /// doc and shows a "access removed" message rather than racing the
  /// teacher's session over who owns the user doc.
  Future<void> removeTeacher({
    required String orgId,
    required String teacherUid,
  }) async {
    try {
      await _teachers(orgId).doc(teacherUid).delete();
    } catch (e, st) {
      appLog('removeTeacher', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<OrgInvite>> watchInvites(String orgId) {
    return _invites(orgId).snapshots().map((snap) {
      final list = <OrgInvite>[];
      for (final doc in snap.docs) {
        final invite = OrgInvite.fromFirestore(doc);
        if (invite != null) list.add(invite);
      }
      return list;
    });
  }

  /// Finds a pending invite across all orgs matching [email] — read-only,
  /// does not claim it. If the same email was invited to more than one org
  /// (a rare collision), the oldest invite wins so the result is
  /// deterministic instead of whatever Firestore happens to return first.
  Future<PendingTeacherInvite?> findPendingInvite({
    required String email,
  }) async {
    try {
      final emailLower = email.trim().toLowerCase();
      final query = await _firestore
          .collectionGroup('invites')
          .where('email', isEqualTo: emailLower)
          .where('status', isEqualTo: InviteStatus.pending.firestoreValue)
          .orderBy('invitedAt')
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      final orgId = query.docs.first.reference.parent.parent?.id;
      if (orgId == null) return null;
      final orgDoc = await _orgs.doc(orgId).get();
      final orgName = orgDoc.data()?['name'] as String? ?? 'an organization';
      return PendingTeacherInvite(orgId: orgId, orgName: orgName);
    } catch (e, st) {
      appLog('findPendingInvite', error: e, stackTrace: st);
      return null;
    }
  }

  /// Claims the pending invite for [email] under [orgId]: marks it claimed
  /// and writes the teacher membership doc.
  Future<void> claimInvite({
    required String orgId,
    required String email,
    required String uid,
    required String name,
  }) async {
    try {
      final emailLower = email.trim().toLowerCase();
      await _invites(orgId).doc(emailLower).set({
        'status': InviteStatus.claimed.firestoreValue,
        'claimedByUid': uid,
      }, SetOptions(merge: true));
      await _teachers(orgId).doc(uid).set({
        'uid': uid,
        'name': name,
        'email': emailLower,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLog('claimInvite', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Convenience for callers that don't need a confirmation gate (e.g. a
  /// brand-new signup has no prior role to protect): finds and immediately
  /// claims a pending invite in one step. Returns the claimed orgId, or
  /// null if no pending invite exists.
  Future<String?> claimInviteIfAny({
    required String email,
    required String uid,
    required String name,
  }) async {
    final pending = await findPendingInvite(email: email);
    if (pending == null) return null;
    await claimInvite(orgId: pending.orgId, email: email, uid: uid, name: name);
    return pending.orgId;
  }

  Stream<List<TeacherMembership>> watchTeachers(String orgId) {
    return _teachers(orgId).snapshots().map((snap) {
      final list = <TeacherMembership>[];
      for (final doc in snap.docs) {
        final t = TeacherMembership.fromFirestore(doc);
        if (t != null) list.add(t);
      }
      return list;
    });
  }

  Stream<TeacherMembership?> watchTeacherMembership({
    required String orgId,
    required String uid,
  }) {
    return _teachers(
      orgId,
    ).doc(uid).snapshots().map(TeacherMembership.fromFirestore);
  }

  Future<String> createClass({
    required String orgId,
    required String teacherUid,
    required String name,
  }) async {
    try {
      final doc = _classes(orgId).doc();
      await doc.set({
        'orgId': orgId,
        'teacherUid': teacherUid,
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e, st) {
      appLog('createClass', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<SchoolClass>> watchClassesForTeacher({
    required String orgId,
    required String teacherUid,
  }) {
    return _classes(
      orgId,
    ).where('teacherUid', isEqualTo: teacherUid).snapshots().map((snap) {
      final list = <SchoolClass>[];
      for (final doc in snap.docs) {
        final c = SchoolClass.fromFirestore(doc);
        if (c != null) list.add(c);
      }
      return list;
    });
  }

  Stream<List<SchoolClass>> watchAllClassesForOrg(String orgId) {
    return _classes(orgId).snapshots().map((snap) {
      final list = <SchoolClass>[];
      for (final doc in snap.docs) {
        final c = SchoolClass.fromFirestore(doc);
        if (c != null) list.add(c);
      }
      return list;
    });
  }

  Future<String> addStudent({
    required String orgId,
    required String classId,
    required String teacherUid,
    required String name,
  }) async {
    try {
      final doc = _students(orgId, classId).doc();
      await doc.set({
        'classId': classId,
        'orgId': orgId,
        'teacherUid': teacherUid,
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e, st) {
      appLog('addStudent', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<Student>> watchStudentsForClass({
    required String orgId,
    required String classId,
  }) {
    return _students(orgId, classId).snapshots().map((snap) {
      final list = <Student>[];
      for (final doc in snap.docs) {
        final s = Student.fromFirestore(doc);
        if (s != null) list.add(s);
      }
      return list;
    });
  }
}
