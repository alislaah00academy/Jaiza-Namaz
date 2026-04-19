// Declarative routes + auth redirects. Refresh on Firebase userChanges()
// so email verification updates without app restart.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/auth/presentation/change_password_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/benefits/presentation/benefits_screen.dart';
import '../features/contact/presentation/contact_screen.dart';
import '../features/donation/presentation/donation_screen.dart';
import '../features/fard/presentation/fard_prayers_screen.dart';
import '../features/home/presentation/app_shell.dart';
import '../features/home/presentation/home_hub_screen.dart';
import '../features/misc/presentation/coming_soon_screen.dart';
import '../features/nawafil/presentation/nawafil_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/qaza/presentation/qaza_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'go_router_refresh.dart';
import '../providers/providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

String? _redirect(BuildContext context, GoRouterState state) {
  final loc = state.matchedLocation;
  final user = FirebaseAuth.instance.currentUser;

  if (loc == '/splash') {
    return null;
  }

  if (user == null) {
    const public = {
      '/welcome',
      '/login',
      '/signup',
      '/reset-password',
    };
    if (public.contains(loc)) return null;
    return '/welcome';
  }

  if (!user.emailVerified) {
    if (loc == '/verify-email') return null;
    return '/verify-email';
  }

  const preApp = {
    '/welcome',
    '/login',
    '/signup',
    '/reset-password',
    '/verify-email',
    '/splash',
  };
  if (preApp.contains(loc)) {
    return '/app/home';
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
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
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
        path: '/app',
        redirect: (context, state) =>
            state.uri.path == '/app' ? '/app/home' : null,
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(
              location: state.uri.path,
              child: child,
            ),
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
                path: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: 'coming-soon',
                builder: (context, state) {
                  final title = state.uri.queryParameters['title'];
                  return ComingSoonScreen(featureTitle: title);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
