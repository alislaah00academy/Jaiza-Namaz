import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `users/{userId}` — document id matches Auth UID.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.city,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.nawafilEnabled = false,
    this.qazaBacklogYears = 0,
    this.qazaBacklogMonths = 0,
    this.qazaBacklogDays = 0,
    this.qazaDailyTarget = 1,
  });

  final String uid;
  final String name;
  final String email;
  final int? age;
  final String? city;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool nawafilEnabled;
  final int qazaBacklogYears;
  final int qazaBacklogMonths;
  final int qazaBacklogDays;
  final int qazaDailyTarget;

  /// Estimated total Fard prayers missed (rough heuristic for UX; documented in UI).
  int get estimatedQazaPrayers {
    final y = qazaBacklogYears * 365 * 5;
    final m = qazaBacklogMonths * 30 * 5;
    final d = qazaBacklogDays * 5;
    return y + m + d;
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (age != null) 'age': age,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'nawafilEnabled': nawafilEnabled,
      'qazaBacklogYears': qazaBacklogYears,
      'qazaBacklogMonths': qazaBacklogMonths,
      'qazaBacklogDays': qazaBacklogDays,
      'qazaDailyTarget': qazaDailyTarget,
    };
  }

  Map<String, dynamic> toFirestoreMerge() {
    final map = toJson();
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }

  static AppUser? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return null;
    final legacyName = data['displayName'] as String?;
    var name = data['name'] as String? ?? '';
    if (name.isEmpty && legacyName != null && legacyName.isNotEmpty) {
      name = legacyName;
    }
    return AppUser(
      uid: data['uid'] as String? ?? snap.id,
      name: name,
      email: data['email'] as String? ?? '',
      age: (data['age'] as num?)?.toInt(),
      city: data['city'] as String?,
      phone: data['phone'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      nawafilEnabled: data['nawafilEnabled'] as bool? ?? false,
      qazaBacklogYears: (data['qazaBacklogYears'] as num?)?.toInt() ?? 0,
      qazaBacklogMonths: (data['qazaBacklogMonths'] as num?)?.toInt() ?? 0,
      qazaBacklogDays: (data['qazaBacklogDays'] as num?)?.toInt() ?? 0,
      qazaDailyTarget: (data['qazaDailyTarget'] as num?)?.toInt() ?? 1,
    );
  }

  static AppUser fromJson(Map<String, dynamic> data, String uid) {
    final legacyName = data['displayName'] as String?;
    var name = data['name'] as String? ?? '';
    if (name.isEmpty && legacyName != null && legacyName.isNotEmpty) {
      name = legacyName;
    }
    return AppUser(
      uid: data['uid'] as String? ?? uid,
      name: name,
      email: data['email'] as String? ?? '',
      age: (data['age'] as num?)?.toInt(),
      city: data['city'] as String?,
      phone: data['phone'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      nawafilEnabled: data['nawafilEnabled'] as bool? ?? false,
      qazaBacklogYears: (data['qazaBacklogYears'] as num?)?.toInt() ?? 0,
      qazaBacklogMonths: (data['qazaBacklogMonths'] as num?)?.toInt() ?? 0,
      qazaBacklogDays: (data['qazaBacklogDays'] as num?)?.toInt() ?? 0,
      qazaDailyTarget: (data['qazaDailyTarget'] as num?)?.toInt() ?? 1,
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    int? age,
    String? city,
    String? phone,
    bool? nawafilEnabled,
    int? qazaBacklogYears,
    int? qazaBacklogMonths,
    int? qazaBacklogDays,
    int? qazaDailyTarget,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nawafilEnabled: nawafilEnabled ?? this.nawafilEnabled,
      qazaBacklogYears: qazaBacklogYears ?? this.qazaBacklogYears,
      qazaBacklogMonths: qazaBacklogMonths ?? this.qazaBacklogMonths,
      qazaBacklogDays: qazaBacklogDays ?? this.qazaBacklogDays,
      qazaDailyTarget: qazaDailyTarget ?? this.qazaDailyTarget,
    );
  }
}
