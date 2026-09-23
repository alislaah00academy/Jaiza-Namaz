import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';

/// Where a signed-in, verified user should land. Every role shares the
/// same Today shell — Parent adds a child switcher, Organization adds a
/// Classes tab — so this is always `/app/home` regardless of role.
String homeRouteForAppUser(AppUser? appUser) => '/app/home';

/// Same decision, made directly from a role/orgMemberRole pair — for call
/// sites (e.g. right after `setRole`) where the Firestore-backed [AppUser]
/// stream hasn't re-emitted yet and reading it would race the just-written
/// value.
String homeRouteForRole(UserRole role, {OrgMemberRole? orgMemberRole}) =>
    '/app/home';
