import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `users/{parentUid}/children/{childId}` — a phoneless child
/// profile tracked by a Parent-role account.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.parentUid,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String parentUid;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'parentUid': parentUid,
        'name': name,
      };

  static ChildProfile? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    return ChildProfile(
      id: snap.id,
      parentUid: data['parentUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
