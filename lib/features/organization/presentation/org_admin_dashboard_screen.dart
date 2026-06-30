import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/role_badge.dart';
import '../../../data/models/organization.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../providers/providers.dart';

/// Org admin home: invite teachers by email, see every teacher attached to
/// this org, drill into any teacher's classes/students.
class OrgAdminDashboardScreen extends ConsumerWidget {
  const OrgAdminDashboardScreen({super.key});

  Future<void> _inviteTeacher(
    BuildContext context,
    WidgetRef ref,
    String orgId,
  ) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite a teacher'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'teacher@example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send invite'),
          ),
        ],
      ),
    );
    if (email == null || email.trim().isEmpty) return;
    try {
      await ref
          .read(organizationRepositoryProvider)
          .inviteTeacher(orgId: orgId, email: email.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invite sent. They\'ll get teacher access when they sign up or log in with $email.',
            ),
          ),
        );
      }
    } on TeacherAlreadyActiveException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _removeTeacher(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    TeacherMembership teacher,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove teacher?'),
        content: Text(
          '${teacher.name} will lose access to this organization\'s classes '
          'and students. This cannot be undone from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(organizationRepositoryProvider)
        .removeTeacher(orgId: orgId, teacherUid: teacher.uid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(myOrgProvider);
    return orgAsync.when(
      data: (org) {
        if (org == null) {
          return const Center(child: Text('Organization not found.'));
        }
        final teachersAsync = ref.watch(allTeachersForOrgProvider(org.id));
        final classesAsync = ref.watch(allClassesForOrgProvider(org.id));
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _inviteTeacher(context, ref, org.id),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Invite teacher'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const RoleBadge(
                label: 'Admin Dashboard',
                icon: Icons.admin_panel_settings_outlined,
              ),
              const SizedBox(height: 12),
              Text(org.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Teachers', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              teachersAsync.when(
                data: (teachers) {
                  if (teachers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No teachers yet — invite one above.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final t in teachers)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(t.name),
                            subtitle: Text(t.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Remove teacher',
                                  icon: const Icon(
                                    Icons.person_remove_outlined,
                                  ),
                                  onPressed: () =>
                                      _removeTeacher(context, ref, org.id, t),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                            onTap: () =>
                                context.push('/app/org/admin/teacher/${t.uid}'),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Could not load teachers: $e'),
              ),
              const SizedBox(height: 24),
              Text(
                'All classes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              classesAsync.when(
                data: (classes) {
                  if (classes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No classes yet.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final c in classes)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(Icons.class_outlined),
                            title: Text(c.name),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Could not load classes: $e'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load organization: $e')),
    );
  }
}
