import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// One class's roster: add students, mark each student's Fard attendance
/// for today efficiently (single-tap completed/missed toggle per row).
class ClassRosterScreen extends ConsumerWidget {
  const ClassRosterScreen({super.key, required this.classId});

  final String classId;

  Future<void> _addStudent(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    String teacherUid,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a student'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Student's name"),
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
    await ref.read(organizationRepositoryProvider).addStudent(
          orgId: orgId,
          classId: classId,
          teacherUid: teacherUid,
          name: name.trim(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    final teacherUid = appUser?.uid;
    if (orgId == null || teacherUid == null) {
      return const Scaffold(
        body: Center(child: Text('Not attached to an organization yet.')),
      );
    }
    final studentsAsync =
        ref.watch(studentsForClassProvider((orgId: orgId, classId: classId)));

    return Scaffold(
      appBar: AppBar(title: const Text('Class roster')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStudent(context, ref, orgId, teacherUid),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students added yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index];
              final fardMapAsync = ref.watch(studentTodayFardMapProvider(s.id));
              final map = fardMapAsync.valueOrNull ?? const {};
              final completedToday = map.values
                  .where((l) => l.status == PrayerStatus.completed)
                  .length;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(s.name),
                  subtitle: Text('$completedToday/5 marked today'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(
                    '/app/org/teacher/class/$classId/student/${s.id}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load students: $e')),
      ),
    );
  }
}
