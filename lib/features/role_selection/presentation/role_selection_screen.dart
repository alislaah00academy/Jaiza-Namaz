import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/role_home_route.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import 'role_card.dart';

/// Safety net for legacy accounts only: shown once, right after auth, when
/// the signed-in user has no [UserRole] set yet (because they signed up
/// before roles existed). New signups pick their role up-front on
/// `/get-started` instead and never see this screen.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _loading = false;

  Future<void> _choose(UserRole role) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      String destination;
      if (role == UserRole.organization) {
        final name = await askOrgName(context);
        if (name == null || name.trim().isEmpty) {
          setState(() => _loading = false);
          return;
        }
        final orgId = await ref
            .read(organizationRepositoryProvider)
            .createOrganization(adminUid: uid, name: name.trim());
        await ref.read(userRepositoryProvider).setRole(
              uid: uid,
              role: UserRole.organization,
              orgId: orgId,
              orgMemberRole: OrgMemberRole.admin,
            );
        destination = homeRouteForRole(role, orgMemberRole: OrgMemberRole.admin);
      } else {
        await ref.read(userRepositoryProvider).setRole(uid: uid, role: role);
        destination = homeRouteForRole(role);
      }
      if (mounted) context.go(destination);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: JaizaSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'How will you use Jaiza?',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick the setup that fits you. You can\'t change this later.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      RoleCard(
                        icon: Icons.person_outline,
                        title: 'Individual',
                        subtitle: 'Track your own daily prayers, streaks and badges.',
                        loading: _loading,
                        onTap: () => _choose(UserRole.individual),
                      ),
                      const SizedBox(height: 12),
                      RoleCard(
                        icon: Icons.family_restroom_outlined,
                        title: 'Parent',
                        subtitle:
                            'Mark and track prayer attendance for your children.',
                        loading: _loading,
                        onTap: () => _choose(UserRole.parent),
                      ),
                      const SizedBox(height: 12),
                      RoleCard(
                        icon: Icons.school_outlined,
                        title: 'Madarsa / Organization',
                        subtitle:
                            'Run a school or institute: teachers, classes and student attendance.',
                        loading: _loading,
                        onTap: () => _choose(UserRole.organization),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
