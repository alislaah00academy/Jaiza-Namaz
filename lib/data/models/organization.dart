import 'package:cloud_firestore/cloud_firestore.dart';

/// `organizations/{orgId}` — a Madarsa/school account.
class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.adminUid,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String adminUid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static Organization? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return Organization(
      id: snap.id,
      name: data['name'] as String? ?? '',
      adminUid: data['adminUid'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

enum InviteStatus { pending, claimed }

extension InviteStatusX on InviteStatus {
  String get firestoreValue => name;

  static InviteStatus fromFirestore(String? raw) {
    for (final v in InviteStatus.values) {
      if (v.name == raw) return v;
    }
    return InviteStatus.pending;
  }
}

/// `organizations/{orgId}/invites/{emailLower}` — a pending or claimed
/// teacher invitation, keyed by lowercased email.
class OrgInvite {
  const OrgInvite({
    required this.orgId,
    required this.email,
    required this.status,
    this.invitedAt,
    this.claimedByUid,
  });

  final String orgId;
  final String email;
  final InviteStatus status;
  final DateTime? invitedAt;
  final String? claimedByUid;

  static OrgInvite? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    // orgId is the parent of the parent (invites) collection reference.
    final orgId = snap.reference.parent.parent?.id ?? '';
    return OrgInvite(
      orgId: orgId,
      email: data['email'] as String? ?? snap.id,
      status: InviteStatusX.fromFirestore(data['status'] as String?),
      invitedAt: (data['invitedAt'] as Timestamp?)?.toDate(),
      claimedByUid: data['claimedByUid'] as String?,
    );
  }
}

/// `organizations/{orgId}/teachers/{teacherUid}`.
class TeacherMembership {
  const TeacherMembership({
    required this.uid,
    required this.orgId,
    required this.name,
    required this.email,
    this.joinedAt,
  });

  final String uid;
  final String orgId;
  final String name;
  final String email;
  final DateTime? joinedAt;

  static TeacherMembership? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    final orgId = snap.reference.parent.parent?.id ?? '';
    return TeacherMembership(
      uid: data['uid'] as String? ?? snap.id,
      orgId: orgId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// `organizations/{orgId}/classes/{classId}`.
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.orgId,
    required this.teacherUid,
    required this.name,
    this.createdAt,
  });

  final String id;
  final String orgId;
  final String teacherUid;
  final String name;
  final DateTime? createdAt;

  static SchoolClass? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return SchoolClass(
      id: snap.id,
      orgId: data['orgId'] as String? ?? '',
      teacherUid: data['teacherUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// `organizations/{orgId}/classes/{classId}/students/{studentId}`.
class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.orgId,
    required this.teacherUid,
    required this.name,
    this.createdAt,
  });

  final String id;
  final String classId;
  final String orgId;
  final String teacherUid;
  final String name;
  final DateTime? createdAt;

  static Student? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return Student(
      id: snap.id,
      classId: data['classId'] as String? ?? '',
      orgId: data['orgId'] as String? ?? '',
      teacherUid: data['teacherUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
