import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../providers/providers.dart';

/// Entry splash: animated logo reveal, then routes to onboarding (first
/// install), the app, or the welcome flow depending on state.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    final onboardingDone = ref.read(onboardingRepositoryProvider).isComplete;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      context.go('/app/home');
    } else if (user != null) {
      context.go('/verify-email');
    } else if (!onboardingDone) {
      context.go('/onboarding');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.colorScheme.tertiary;
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: AuthMaxWidth(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo: fade + scale up with a gentle settle, then a
                  // one-pass shimmer sweep across the gold artwork.
                  const JaizaWordmark(maxSize: 200)
                      .animate()
                      .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then(delay: 200.ms)
                      .shimmer(
                        duration: 1100.ms,
                        color: gold.withValues(alpha: 0.6),
                      ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.startWithSalaam,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 600.ms).moveY(begin: 12, end: 0),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: gold,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
