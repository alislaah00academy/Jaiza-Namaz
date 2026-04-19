import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Entry splash: Salaam + academy credit, then routes by auth state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      context.go('/app/home');
    } else if (user != null) {
      context.go('/verify-email');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(context),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mosque_rounded,
                  size: 88,
                  color: theme.colorScheme.primary,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.85, 0.85)),
                const SizedBox(height: 24),
                Text(
                  AppStrings.startWithSalaam,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 32),
                Text(
                  AppStrings.academyCredit,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
