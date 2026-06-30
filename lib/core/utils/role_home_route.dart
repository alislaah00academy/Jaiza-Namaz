import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';

/// Where a signed-in, verified user should land: the Individual home hub,
/// or the dashboard matching their Parent/Organization role.
String homeRouteForAppUser(AppUser? appUser) {
  switch (appUser?.role) {
    case UserRole.parent:
      return '/app/parent';
    case UserRole.organization:
      return appUser?.orgMemberRole == OrgMemberRole.teacher
          ? '/app/org/teacher'
          : '/app/org/admin';
    case UserRole.individual:
    case null:
      return '/app/home';
  }
}

/// Same decision, made directly from a role/orgMemberRole pair — for call
/// sites (e.g. right after `setRole`) where the Firestore-backed [AppUser]
/// stream hasn't re-emitted yet and reading it would race the just-written
/// value.
String homeRouteForRole(UserRole role, {OrgMemberRole? orgMemberRole}) {
  switch (role) {
    case UserRole.parent:
      return '/app/parent';
    case UserRole.organization:
      return orgMemberRole == OrgMemberRole.teacher
          ? '/app/org/teacher'
          : '/app/org/admin';
    case UserRole.individual:
      return '/app/home';
  }
}
