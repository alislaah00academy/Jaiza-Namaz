import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/role_badge.dart';
import '../../../providers/providers.dart';

/// Teacher home: list of classes/sections this teacher created, create new.
class OrgTeacherDashboardScreen extends ConsumerWidget {
  const OrgTeacherDashboardScreen({super.key});

  Future<void> _createClass(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    String teacherUid,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New class / section'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Batch A'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(organizationRepositoryProvider)
        .createClass(orgId: orgId, teacherUid: teacherUid, name: name.trim());
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    if (uid == null || orgId == null) {
      return const Center(child: Text('Not attached to an organization yet.'));
    }

    final membershipAsync = ref.watch(myTeacherMembershipProvider);
    if (membershipAsync.hasValue && membershipAsync.value == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your access to this organization has been removed.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _signOut(context, ref),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final classesAsync = ref.watch(classesForTeacherProvider);
    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RoleBadge(
                    label: 'Teacher Dashboard',
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.class_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text('No classes yet.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _createClass(context, ref, orgId, uid),
                    icon: const Icon(Icons.add),
                    label: const Text('Create a class'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createClass(context, ref, orgId, uid),
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: RoleBadge(
                    label: 'Teacher Dashboard',
                    icon: Icons.school_outlined,
                  ),
                );
              }
              final c = classes[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.class_outlined),
                  ),
                  title: Text(c.name),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/app/org/teacher/class/${c.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load classes: $e')),
    );
  }
}
