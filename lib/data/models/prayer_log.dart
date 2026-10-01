import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaiza_core/jaiza_core.dart';

import '../../core/firestore/converters.dart';

// The model and its enums live in jaiza_core (shared with Functions and the
// dashboard, D-008); this file keeps the Firestore read/write helpers.
export 'package:jaiza_core/jaiza_core.dart'
    show PrayerLog, PrayerName, PrayerStatus, PrayerType, PrayerLogSource;

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

/// Builds the Firestore map for a `{subject}/prayers/{logId}` write (06 §2.2).
/// `markedAt` is always the server's time; `dateTime` keeps the client's
/// instant for the legacy "UTC of window start" queries.
Map<String, dynamic> prayerLogWriteData({
  required PrayerName prayerName,
  required PrayerType type,
  required String markedBy,
  required PrayerLogSource source,
  required DateTime dateTime,
  PrayerStatus? status,
  int count = 0,
  bool? inJamaat,
}) {
  return {
    'dateKey': DateKeys.of(dateTime),
    'prayerName': prayerName.name,
    'type': type.name,
    if (status != null) 'status': status.name,
    'count': count,
    'inJamaat': ?inJamaat,
    'markedBy': markedBy,
    'source': source.name,
    'markedAt': FieldValue.serverTimestamp(),
    'dateTime': Timestamp.fromDate(dateTime),
  };
}

/// Reads one `{subject}/prayers/{logId}` snapshot into a [PrayerLog].
PrayerLog? prayerLogFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
  final data = snap.data();
  if (data == null) return null;
  try {
    return PrayerLog.fromJson(FirestoreJson.decode(data));
  } catch (_) {
    return null;
  }
}
