/// Top-level account type. `null`/unset is the legacy/undecided state.
enum UserRole { individual, parent, organization }

extension UserRoleX on UserRole {
  String get firestoreValue => name;

  static UserRole? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in UserRole.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

/// Disambiguates the two organization-side accounts: the admin who created
/// the organization vs. a teacher attached to it via an invite.
enum OrgMemberRole { admin, teacher }

extension OrgMemberRoleX on OrgMemberRole {
  String get firestoreValue => name;

  static OrgMemberRole? fromFirestore(String? raw) {
    if (raw == null) return null;
    for (final v in OrgMemberRole.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
