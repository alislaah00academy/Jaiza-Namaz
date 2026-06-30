// Declarative routes + auth redirects. Refresh on Firebase userChanges()
// so email verification updates without app restart.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/role_home_route.dart';
import '../data/models/user_role.dart';
import '../features/about/presentation/about_screen.dart';
import '../features/about/presentation/academy_intro_screen.dart';
import '../features/auth/presentation/change_password_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';
import '../features/auth/presentation/get_started_role_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/benefits/presentation/benefits_screen.dart';
import '../features/contact/presentation/contact_screen.dart';
import '../features/donation/presentation/donation_screen.dart';
import '../features/fard/presentation/fard_prayers_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/app_shell.dart';
import '../features/home/presentation/home_hub_screen.dart';
import '../features/misc/presentation/coming_soon_screen.dart';
import '../features/nawafil/presentation/nawafil_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/organization/presentation/class_roster_screen.dart';
import '../features/organization/presentation/org_admin_dashboard_screen.dart';
import '../features/organization/presentation/org_admin_drilldown_screen.dart';
import '../features/organization/presentation/org_teacher_dashboard_screen.dart';
import '../features/organization/presentation/student_history_screen.dart';
import '../features/parent/presentation/child_attendance_screen.dart';
import '../features/parent/presentation/child_history_screen.dart';
import '../features/parent/presentation/parent_dashboard_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/role_selection/presentation/role_selection_screen.dart';
import '../features/settings/presentation/widgets_notifications_screen.dart';
import '../features/qaza/presentation/qaza_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'go_router_refresh.dart';
import '../providers/providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _knownTopLevel = <String>{
  '/splash',
  '/onboarding',
  '/welcome',
  '/get-started',
  '/login',
  '/signup',
  '/verify-email',
  '/reset-password',
  '/select-role',
};

String? _redirect(BuildContext context, GoRouterState state, Ref ref) {
  // Widget deep links (jaiza://...) and unknown paths must not hit GoRouter's
  // error page — bounce to splash so auth redirect + HomeWidgetBridge can run.
  if (state.uri.scheme == 'jaiza') {
    return '/splash';
  }
  final loc = state.matchedLocation;
  final isKnown =
      _knownTopLevel.contains(loc) || loc == '/app' || loc.startsWith('/app/');
  if (!isKnown) {
    return '/splash';
  }

  final user = FirebaseAuth.instance.currentUser;

  if (loc == '/splash') {
    return null;
  }

  if (user == null) {
    // First-launch onboarding gate: a signed-out user who hasn't completed
    // onboarding yet may stay on /onboarding; everything else for a
    // signed-out user remains reachable as before.
    final onboardingDone = ref.read(onboardingRepositoryProvider).isComplete;
    if (loc == '/onboarding') {
      return onboardingDone ? '/welcome' : null;
    }
    const public = {
      '/welcome',
      '/get-started',
      '/login',
      '/signup',
      '/reset-password',
    };
    if (public.contains(loc)) return null;
    return onboardingDone ? '/welcome' : '/onboarding';
  }

  if (!user.emailVerified) {
    if (loc == '/verify-email') return null;
    return '/verify-email';
  }

  // Role selection: legacy/new users with no role chosen yet are routed to
  // pick Individual/Parent/Organization before reaching the app. Accounts
  // auto-attached as org teachers (invite-claim on login/signup) already
  // have a role by this point and skip straight through.
  final appUser = ref.read(appUserStreamProvider).valueOrNull;
  if (appUser != null && appUser.role == null) {
    if (loc == '/select-role') return null;
    return '/select-role';
  }
  if (appUser?.role != null && loc == '/select-role') {
    return homeRouteForAppUser(appUser);
  }

  // Defense-in-depth: AppShell's nav only ever offers a user the routes for
  // their own role, but nothing stops a manual `context.go()`/deep link to
  // a mismatched dashboard. Bounce back to the correct one instead of
  // rendering an empty/"not found" screen for the wrong role.
  if (loc.startsWith('/app/parent') && appUser?.role != UserRole.parent) {
    return homeRouteForAppUser(appUser);
  }
  if (loc.startsWith('/app/org/admin') &&
      appUser?.orgMemberRole != OrgMemberRole.admin) {
    return homeRouteForAppUser(appUser);
  }
  if (loc.startsWith('/app/org/teacher') &&
      appUser?.orgMemberRole != OrgMemberRole.teacher) {
    return homeRouteForAppUser(appUser);
  }

  const preApp = {
    '/welcome',
    '/get-started',
    '/login',
    '/signup',
    '/reset-password',
    '/verify-email',
    '/splash',
  };
  if (preApp.contains(loc)) {
    return homeRouteForAppUser(appUser);
  }

  return null;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = GoRouterRefreshStream(auth.userChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(context, state, ref),
    errorBuilder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) GoRouter.of(context).go('/splash');
      });
      return const Scaffold(body: SizedBox.shrink());
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/get-started',
        builder: (context, state) => const GetStartedRoleScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(
          initialRole: UserRoleX.fromFirestore(
            state.uri.queryParameters['role'],
          ),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/app',
        redirect: (context, state) =>
            state.uri.path == '/app' ? '/app/home' : null,
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(location: state.uri.path, child: child),
            routes: [
              GoRoute(
                path: 'home',
                builder: (context, state) => const HomeHubScreen(),
              ),
              GoRoute(
                path: 'fard',
                builder: (context, state) => const FardPrayersScreen(),
              ),
              GoRoute(
                path: 'nawafil',
                builder: (context, state) => const NawafilScreen(),
              ),
              GoRoute(
                path: 'qaza',
                builder: (context, state) => const QazaScreen(),
              ),
              GoRoute(
                path: 'benefits',
                builder: (context, state) => const BenefitsScreen(),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
              GoRoute(
                path: 'academy-intro',
                builder: (context, state) => const AcademyIntroScreen(),
              ),
              GoRoute(
                path: 'contact',
                builder: (context, state) => const ContactScreen(),
              ),
              GoRoute(
                path: 'donation',
                builder: (context, state) => const DonationScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'widget-settings',
                builder: (context, state) => const WidgetsNotificationsScreen(),
              ),
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
              GoRoute(
                path: 'reminders',
                builder: (context, state) => const RemindersScreen(),
              ),
              GoRoute(
                path: 'coming-soon',
                builder: (context, state) {
                  final title = state.uri.queryParameters['title'];
                  return ComingSoonScreen(featureTitle: title);
                },
              ),
              GoRoute(
                path: 'parent',
                builder: (context, state) => const ParentDashboardScreen(),
              ),
              GoRoute(
                path: 'parent/child/:childId',
                builder: (context, state) => ChildAttendanceScreen(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'parent/child/:childId/history',
                builder: (context, state) => ChildHistoryScreen(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'org/admin',
                builder: (context, state) => const OrgAdminDashboardScreen(),
              ),
              GoRoute(
                path: 'org/admin/teacher/:teacherUid',
                builder: (context, state) => OrgAdminDrilldownScreen(
                  teacherUid: state.pathParameters['teacherUid']!,
                ),
              ),
              GoRoute(
                path: 'org/teacher',
                builder: (context, state) => const OrgTeacherDashboardScreen(),
              ),
              GoRoute(
                path: 'org/teacher/class/:classId',
                builder: (context, state) => ClassRosterScreen(
                  classId: state.pathParameters['classId']!,
                ),
              ),
              GoRoute(
                path: 'org/teacher/class/:classId/student/:studentId',
                builder: (context, state) => StudentHistoryScreen(
                  classId: state.pathParameters['classId']!,
                  studentId: state.pathParameters['studentId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
