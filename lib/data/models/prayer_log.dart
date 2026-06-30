import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/date_utils.dart';

/// Stored as lowercase string in Firestore.
enum PrayerName {
  fajr,
  zuhr,
  asr,
  maghrib,
  isha,
  witr,
  tahajjud,
  ishraq,
  chasht,
  awwabin,
  rawatib,
  taraweeh,
  qazaGeneric,
}

extension PrayerNameX on PrayerName {
  String get firestoreValue => name;

  static PrayerName? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in PrayerName.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

enum PrayerType { fard, nawafil, qaza }

extension PrayerTypeX on PrayerType {
  String get firestoreValue => name;

  static PrayerType? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in PrayerType.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

enum PrayerStatus { completed, missed }

extension PrayerStatusX on PrayerStatus {
  String get firestoreValue => name;

  static PrayerStatus? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in PrayerStatus.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

/// Firestore document in `prayers` collection.
/// [dateTime] is stored as UTC Timestamp per app convention.
class PrayerLog {
  const PrayerLog({
    required this.id,
    required this.userId,
    required this.prayerName,
    required this.type,
    required this.status,
    required this.dateTime,
    this.ownerUid,
  });

  final String id;
  final String userId;
  final PrayerName prayerName;
  final PrayerType type;
  final PrayerStatus status;
  final DateTime dateTime;

  /// Set when this log belongs to a Parent's child or an Organization's
  /// student: the Firebase Auth uid of the account that owns/manages this
  /// log (the parent, or the teacher). `null` for Individual logs.
  final String? ownerUid;

  /// Deterministic id: one row per user / local day / prayer / type (latest wins).
  static String deterministicId({
    required String userId,
    required String localDateKey,
    required PrayerName prayerName,
    required PrayerType type,
  }) {
    return '${userId}_${localDateKey}_${prayerName.name}_${type.name}';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'prayerName': prayerName.firestoreValue,
      'type': type.firestoreValue,
      'status': status.firestoreValue,
      'dateTime': AppDateUtils.dateTimeToTimestampUtc(dateTime),
      if (ownerUid != null) 'ownerUid': ownerUid,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  static PrayerLog? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return null;
    final name = PrayerNameX.fromFirestore(data['prayerName'] as String?);
    final type = PrayerTypeX.fromFirestore(data['type'] as String?);
    final status = PrayerStatusX.fromFirestore(data['status'] as String?);
    final ts = data['dateTime'] as Timestamp?;
    if (name == null || type == null || status == null || ts == null) {
      return null;
    }
    return PrayerLog(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      prayerName: name,
      type: type,
      status: status,
      dateTime: AppDateUtils.timestampToLocalDateTime(ts),
      ownerUid: data['ownerUid'] as String?,
    );
  }

  static PrayerLog? fromJson(Map<String, dynamic> data, String id) {
    final name = PrayerNameX.fromFirestore(data['prayerName'] as String?);
    final type = PrayerTypeX.fromFirestore(data['type'] as String?);
    final status = PrayerStatusX.fromFirestore(data['status'] as String?);
    final ts = data['dateTime'];
    DateTime? dt;
    if (ts is Timestamp) {
      dt = AppDateUtils.timestampToLocalDateTime(ts);
    }
    if (name == null || type == null || status == null || dt == null) {
      return null;
    }
    return PrayerLog(
      id: id,
      userId: data['userId'] as String? ?? '',
      prayerName: name,
      type: type,
      status: status,
      dateTime: dt,
      ownerUid: data['ownerUid'] as String?,
    );
  }
}
