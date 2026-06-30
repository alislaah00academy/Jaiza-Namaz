import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/role_badge.dart';
import '../../../data/models/child_profile.dart';
import '../../../providers/providers.dart';

/// Parent role home: list of children, add new, jump into a child's
/// attendance marking / history.
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  Future<void> _addChild(BuildContext context, WidgetRef ref) async {
    final parentUid = ref.read(currentUserProvider)?.uid;
    if (parentUid == null) return;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a child'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Child's name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(childrenRepositoryProvider)
        .addChild(parentUid: parentUid, name: name.trim());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenStreamProvider);
    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RoleBadge(
                    label: 'Parent Dashboard',
                    icon: Icons.family_restroom_outlined,
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.family_restroom_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text('No children added yet.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _addChild(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add a child'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addChild(context, ref),
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: RoleBadge(
                    label: 'Parent Dashboard',
                    icon: Icons.family_restroom_outlined,
                  ),
                );
              }
              final ChildProfile child = children[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.child_care)),
                  title: Text(child.name),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/app/parent/child/${child.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load children: $e')),
    );
  }
}
