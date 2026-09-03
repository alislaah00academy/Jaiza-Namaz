import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: AuthMaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                JaizaArchCrown(
                  height: 230,
                  child: const JaizaWordmark(),
                ).jaizaEnter(beginY: 0.1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Centre the wordmark + tagline in the space between
                        // the arch and the action buttons (was top-aligned
                        // with a large gap above the buttons).
                        const Spacer(),
                        Text(
                          AppStrings.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ).jaizaEnter(index: 1),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ).jaizaEnter(index: 2),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Log in'),
                        ).jaizaEnter(index: 3),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          style: AppTheme.tonalButtonStyle(context),
                          onPressed: () => context.go('/get-started'),
                          child: const Text('Create account'),
                        ).jaizaEnter(index: 4),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const JaizaMosqueSkyline(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
