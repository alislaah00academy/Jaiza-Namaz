import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';

/// Admin's read-only view of one teacher: contact, their classes with
/// today's completion, and "Remove from organization".
class AdminTeacherScreen extends ConsumerWidget {
  const AdminTeacherScreen({super.key, required this.teacherUid});

  final String teacherUid;

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from organization?'),
        content: Text(
          '$name will lose access to this organization\'s classes and '
          'students. Their classes stay; you can reassign them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(organizationRepositoryProvider)
        .removeTeacher(orgId: orgId, teacherUid: teacherUid);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final org = ref.watch(myOrgProvider).valueOrNull;
    if (org == null) {
      return const Center(child: Text('Organization not found.'));
    }

    final teachers =
        ref.watch(allTeachersForOrgProvider(org.id)).valueOrNull ?? const [];
    final matches = teachers.where((tt) => tt.uid == teacherUid);
    if (matches.isEmpty) return const Center(child: Text('Teacher not found.'));
    final teacher = matches.first;
    final classes =
        (ref.watch(allClassesForOrgProvider(org.id)).valueOrNull ?? const [])
            .where((cl) => cl.teacherUid == teacherUid)
            .toList();
    final sections = ref.watch(classSectionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const JzAvatar(
                    icon: Icons.person_outline_rounded,
                    size: 44,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.name, style: t.titleMedium),
                        Text(
                          teacher.joinedAt == null
                              ? teacher.email
                              : '${teacher.email} · joined '
                                    '${DateFormat('d MMMM').format(teacher.joinedAt!)}',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Read-only. Marking attendance stays with the teacher.',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (classes.isEmpty)
          JzCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'This teacher has no classes yet.',
              style: t.bodyMedium,
            ),
          )
        else
          for (final cl in classes)
            Builder(
              builder: (context) {
                final students =
                    ref
                        .watch(
                          studentsForClassProvider((
                            orgId: org.id,
                            classId: cl.id,
                          )),
                        )
                        .valueOrNull ??
                    const [];
                final pct = students.isEmpty
                    ? 0
                    : (classTodayFraction(ref, [
                                for (final s in students) s.id,
                              ]) *
                              100)
                          .round();
                return JzCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const JzAvatar(
                            icon: Icons.class_outlined,
                            size: 40,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cl.name, style: t.titleSmall),
                                Text(
                                  '${students.length} students'
                                  '${sections[cl.id] == null ? '' : ' · ${sections[cl.id]}'}',
                                  style: t.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text('$pct%', style: t.titleSmall),
                          const JzChevron(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      JzBar(value: pct / 100),
                    ],
                  ),
                );
              },
            ),
        const SizedBox(height: 8),
        JzCard(
          onTap: () => _remove(context, ref, org.id, teacher.name),
          child: JzListRow(
            leading: Icon(Icons.person_remove_outlined, color: c.error),
            title: 'Remove from organization',
            titleColor: c.error,
            subtitle: 'Their classes stay; you can reassign them',
          ),
        ),
      ],
    );
  }
}
