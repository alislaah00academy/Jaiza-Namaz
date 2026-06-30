import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/logging/app_log.dart';
import '../models/child_profile.dart';

/// `users/{parentUid}/children` subcollection.
class ChildrenRepository {
  ChildrenRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _children(String parentUid) =>
      _firestore.collection('users').doc(parentUid).collection('children');

  Stream<List<ChildProfile>> watchChildren(String parentUid) {
    return _children(parentUid).orderBy('createdAt').snapshots().map((snap) {
      final list = <ChildProfile>[];
      for (final doc in snap.docs) {
        final child = ChildProfile.fromFirestore(doc);
        if (child != null) list.add(child);
      }
      return list;
    });
  }

  Future<String> addChild({
    required String parentUid,
    required String name,
  }) async {
    try {
      final doc = _children(parentUid).doc();
      await doc.set({
        'parentUid': parentUid,
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e, st) {
      appLog('addChild', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> renameChild({
    required String parentUid,
    required String childId,
    required String name,
  }) async {
    try {
      await _children(parentUid).doc(childId).set(
        {
          'name': name.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e, st) {
      appLog('renameChild', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteChild({
    required String parentUid,
    required String childId,
  }) async {
    try {
      await _children(parentUid).doc(childId).delete();
    } catch (e, st) {
      appLog('deleteChild', error: e, stackTrace: st);
      rethrow;
    }
  }
}
