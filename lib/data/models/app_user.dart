import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/qaza/data/qaza_plan.dart';
import '../../features/settings/data/prayer_settings.dart';
import 'user_role.dart';

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
    this.prayerSettings,
    this.role,
    this.orgId,
    this.orgMemberRole,
    this.qazaPlan,
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

  /// Widget + notification preferences (see [PrayerSettingsParsed]).
  final Map<String, dynamic>? prayerSettings;

  /// Account type. `null` means the user hasn't picked one yet (legacy
  /// Individual users included) — treated as "needs role selection".
  final UserRole? role;

  /// Set when [role] is [UserRole.organization]: the org this account
  /// owns (admin) or has been attached to as a teacher.
  final String? orgId;

  /// Disambiguates admin vs. teacher when [role] is [UserRole.organization].
  final OrgMemberRole? orgMemberRole;

  /// Per-prayer Qaza backlog + reminder frequency (see [QazaPlanParsed]).
  /// Supersedes the legacy combined `qazaBacklog*`/`qazaDailyTarget`
  /// fields below, which are kept read/write for backward compatibility
  /// but no longer driven by the Qaza screen.
  final Map<String, dynamic>? qazaPlan;

  PrayerSettingsParsed get prayerSettingsParsed =>
      PrayerSettingsParsed.fromRaw(prayerSettings);

  QazaPlanParsed get qazaPlanParsed => QazaPlanParsed.fromRaw(qazaPlan);

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
      if (prayerSettings != null) 'prayerSettings': prayerSettings,
      if (qazaPlan != null) 'qazaPlan': qazaPlan,
      if (role != null) 'role': role!.firestoreValue,
      if (orgId != null) 'orgId': orgId,
      if (orgMemberRole != null) 'orgMemberRole': orgMemberRole!.firestoreValue,
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
      prayerSettings: data['prayerSettings'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['prayerSettings'] as Map)
          : null,
      role: UserRoleX.fromFirestore(data['role'] as String?),
      orgId: data['orgId'] as String?,
      orgMemberRole: OrgMemberRoleX.fromFirestore(
        data['orgMemberRole'] as String?,
      ),
      qazaPlan: data['qazaPlan'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['qazaPlan'] as Map)
          : null,
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
      prayerSettings: data['prayerSettings'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['prayerSettings'] as Map)
          : null,
      role: UserRoleX.fromFirestore(data['role'] as String?),
      orgId: data['orgId'] as String?,
      orgMemberRole: OrgMemberRoleX.fromFirestore(
        data['orgMemberRole'] as String?,
      ),
      qazaPlan: data['qazaPlan'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['qazaPlan'] as Map)
          : null,
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
    Map<String, dynamic>? prayerSettings,
    UserRole? role,
    String? orgId,
    OrgMemberRole? orgMemberRole,
    Map<String, dynamic>? qazaPlan,
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
      prayerSettings: prayerSettings ?? this.prayerSettings,
      qazaPlan: qazaPlan ?? this.qazaPlan,
      role: role ?? this.role,
      orgId: orgId ?? this.orgId,
      orgMemberRole: orgMemberRole ?? this.orgMemberRole,
    );
  }
}
