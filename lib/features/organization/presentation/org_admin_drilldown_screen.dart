import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';

/// Read-only: an org admin viewing one teacher's classes and each class's
/// students. No marking here — that stays the teacher's job.
class OrgAdminDrilldownScreen extends ConsumerWidget {
  const OrgAdminDrilldownScreen({super.key, required this.teacherUid});

  final String teacherUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(myOrgProvider);
    return orgAsync.when(
      data: (org) {
        if (org == null) {
          return const Scaffold(
            body: Center(child: Text('Organization not found.')),
          );
        }
        final classesAsync = ref.watch(allClassesForOrgProvider(org.id));
        return Scaffold(
          appBar: AppBar(title: const Text('Teacher classes')),
          body: classesAsync.when(
            data: (allClasses) {
              final classes =
                  allClasses.where((c) => c.teacherUid == teacherUid).toList();
              if (classes.isEmpty) {
                return const Center(child: Text('This teacher has no classes yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final c = classes[index];
                  final studentsAsync = ref.watch(studentsForClassProvider(
                    (orgId: org.id, classId: c.id),
                  ));
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(c.name),
                      children: [
                        studentsAsync.when(
                          data: (students) {
                            if (students.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('No students yet.'),
                              );
                            }
                            return Column(
                              children: [
                                for (final s in students)
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.person_outline),
                                    title: Text(s.name),
                                  ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Text('Could not load students: $e'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Could not load classes: $e')),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Could not load organization: $e')),
    );
  }
}
