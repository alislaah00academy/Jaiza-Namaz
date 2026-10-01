import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/user_role.dart';
import '../../role_selection/presentation/role_card.dart';
import '../../../core/l10n/l10n.dart';

/// Pre-auth: the first thing a new user sees after tapping "Create account"
/// on the Welcome screen. The chosen role is carried into `/signup` as a
/// query param so it's set the moment the account is created — no separate
/// forced screen after email verification.
class GetStartedRoleScreen extends StatelessWidget {
  const GetStartedRoleScreen({super.key});

  void _choose(BuildContext context, UserRole role) {
    context.push('/signup?role=${role.firestoreValue}');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JaizaArchCrown(
                      height: 230,
                      child: const JaizaWordmark(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.getStartedWelcome,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.l10n.getStartedTagline,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          JaizaFlourishDivider(
                            label: context.l10n.chooseAccountType,
                          ),
                          const SizedBox(height: 20),
                          RoleCard(
                            icon: Icons.person_outline,
                            title: context.l10n.roleIndividual,
                            subtitle: context.l10n.roleIndividualSubtitle,
                            loading: false,
                            onTap: () => _choose(context, UserRole.individual),
                          ).jaizaEnter(index: 1),
                          const SizedBox(height: 14),
                          RoleCard(
                            icon: Icons.people_alt_outlined,
                            title: context.l10n.roleParents,
                            subtitle: context.l10n.roleParentsSubtitle,
                            loading: false,
                            onTap: () => _choose(context, UserRole.parent),
                          ).jaizaEnter(index: 2),
                          const SizedBox(height: 14),
                          RoleCard(
                            icon: Icons.account_balance_outlined,
                            title: context.l10n.roleInstitute,
                            subtitle: context.l10n.roleInstituteSubtitle,
                            loading: false,
                            onTap: () =>
                                _choose(context, UserRole.organization),
                          ).jaizaEnter(index: 3),
                          const SizedBox(height: 28),
                          JaizaQuoteBlock(
                            quote: context.l10n.quoteAnkaboot,
                            source: context.l10n.quoteAnkabootSource,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const JaizaMosqueSkyline(),
                    Container(
                      width: double.infinity,
                      color: scheme.secondaryContainer.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.haveAccount,
                            style: textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: Text(context.l10n.logInButton),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: 4,
                start: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  // Reached via context.go (replaces history), so there's no
                  // pop stack to unwind — go back to Welcome explicitly.
                  onPressed: () => context.go('/welcome'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
