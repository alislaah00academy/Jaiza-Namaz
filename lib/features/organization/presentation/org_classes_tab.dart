import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/organization.dart';
import '../../../data/models/prayer_log.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';
import 'org_widgets.dart';

/// The "Classes" tab — an org admin's dashboard, or a teacher's class list,
/// decided by [AppUser.orgMemberRole]. Same tab position in the shell for
/// both, per the design ("the same shell").
class OrgClassesTab extends ConsumerWidget {
  const OrgClassesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    if (appUser?.orgMemberRole == OrgMemberRole.teacher) {
      return const _TeacherClasses();
    }
    return const _AdminDashboard();
  }
}

class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final org = ref.watch(myOrgProvider).valueOrNull;
    if (org == null) {
      return const Center(child: Text('Organization not found.'));
    }
    final teachers =
        ref.watch(allTeachersForOrgProvider(org.id)).valueOrNull ?? const [];
    final classes =
        ref.watch(allClassesForOrgProvider(org.id)).valueOrNull ?? const [];
    final sections = ref.watch(classSectionsProvider);
    var totalStudents = 0;
    var todaySum = 0.0;
    for (final c in classes) {
      final students =
          ref
              .watch(studentsForClassProvider((orgId: org.id, classId: c.id)))
              .valueOrNull ??
          const [];
      totalStudents += students.length;
      todaySum +=
          classTodayFraction(ref, [for (final s in students) s.id]) *
          students.length;
    }
    final todayPct = totalStudents == 0
        ? 0
        : (todaySum / totalStudents * 100).round();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        JzPageTitle(org.name),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JzCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              value: '${teachers.length}',
                              label: 'Teachers',
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              value: '${classes.length}',
                              label: 'Classes',
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              value: '$totalStudents',
                              label: 'Students',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const JzDivider(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Today across the madrasa',
                            style: t.bodyMedium,
                          ),
                        ),
                        Text('$todayPct%', style: t.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    JzBar(value: todayPct / 100),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: JzSectionLabel('Teachers')),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () =>
                        showInviteTeacherSheet(context, ref, org.id),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label: const Text('Invite teacher'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (teachers.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No teachers yet — invite one above.',
                    style: t.bodyMedium,
                  ),
                )
              else
                for (final teacher in teachers)
                  _TeacherRow(org: org, teacher: teacher, classes: classes),
              const SizedBox(height: 18),
              const JzSectionLabel('All classes'),
              JzCard(
                child: Column(
                  children: [
                    if (classes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No classes yet.', style: t.bodyMedium),
                      )
                    else
                      for (var i = 0; i < classes.length; i++)
                        Builder(
                          builder: (context) {
                            final c = classes[i];
                            final students =
                                ref
                                    .watch(
                                      studentsForClassProvider((
                                        orgId: org.id,
                                        classId: c.id,
                                      )),
                                    )
                                    .valueOrNull ??
                                const [];
                            final matches = teachers.where(
                              (tt) => tt.uid == c.teacherUid,
                            );
                            final teacherName = matches.isEmpty
                                ? null
                                : matches.first.name;
                            final pct = students.isEmpty
                                ? null
                                : (classTodayFraction(ref, [
                                            for (final s in students) s.id,
                                          ]) *
                                          100)
                                      .round();
                            return JzListRow(
                              leading: const JzAvatar(
                                icon: Icons.class_outlined,
                                size: 40,
                                iconSize: 20,
                              ),
                              title: c.name,
                              subtitle:
                                  '${sections[c.id] ?? teacherName ?? 'Unassigned'} · ${students.length}',
                              trailing: Text(
                                pct == null ? '—' : '$pct%',
                                style: t.titleSmall?.copyWith(
                                  color: pct == null
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              showDivider: i < classes.length - 1,
                            );
                          },
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: t.headlineSmall),
        Text(label, style: t.labelSmall),
      ],
    );
  }
}

class _TeacherRow extends ConsumerWidget {
  const _TeacherRow({
    required this.org,
    required this.teacher,
    required this.classes,
  });

  final Organization org;
  final TeacherMembership teacher;
  final List<SchoolClass> classes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final mine = classes.where((c) => c.teacherUid == teacher.uid).toList();
    var students = 0;
    for (final c in mine) {
      students +=
          ref
              .watch(studentsForClassProvider((orgId: org.id, classId: c.id)))
              .valueOrNull
              ?.length ??
          0;
    }
    return JzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/app/org/admin/teacher/${teacher.uid}'),
      child: Row(
        children: [
          const JzAvatar(icon: Icons.person_outline_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teacher.name, style: t.titleSmall),
                Text(teacher.email, style: t.bodySmall),
                Text(
                  '${mine.length} ${mine.length == 1 ? 'class' : 'classes'} · $students students',
                  style: t.labelSmall,
                ),
              ],
            ),
          ),
          const JzChevron(),
        ],
      ),
    );
  }
}

class _TeacherClasses extends ConsumerWidget {
  const _TeacherClasses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final uid = ref.watch(currentUserProvider)?.uid;
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    final membership = ref.watch(myTeacherMembershipProvider);

    if (uid == null || orgId == null) {
      return const Center(child: Text('Not attached to an organization yet.'));
    }
    if (membership.hasValue && membership.value == null) {
      return Center(
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
            ],
          ),
        ),
      );
    }

    final classes =
        ref.watch(classesForTeacherProvider).valueOrNull ?? const [];
    final sections = ref.watch(classSectionsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const JzPageTitle('Classes'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Residential students — all five prayers are marked here.',
            style: t.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showNewClassSheet(
                context,
                ref,
                orgId: orgId,
                teacherUid: uid,
                onCreated: (id) => context.push('/app/org/teacher/class/$id'),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New class'),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (classes.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No classes yet — create one above.',
                    style: t.bodyMedium,
                  ),
                )
              else
                for (final c in classes)
                  _ClassCard(
                    orgId: orgId,
                    schoolClass: c,
                    section: sections[c.id],
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassCard extends ConsumerWidget {
  const _ClassCard({
    required this.orgId,
    required this.schoolClass,
    this.section,
  });

  final String orgId;
  final SchoolClass schoolClass;
  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final students =
        ref
            .watch(
              studentsForClassProvider((orgId: orgId, classId: schoolClass.id)),
            )
            .valueOrNull ??
        const [];
    final schedule = ref.watch(currentPrayerCardProvider).valueOrNull;
    final activeKey =
        schedule?.status.activePrayerKey ?? schedule?.status.nextKey;
    final activeLabel = schedule?.status.activePrayerKey != null
        ? schedule!.today.fardWindows
              .firstWhere((w) => w.key == activeKey)
              .label
        : (schedule?.status.nextLabel ?? 'Fajr');
    final prayer = activeKey == null
        ? null
        : PrayerNameX.fromFirestore(activeKey);
    final (done, total) = prayer == null
        ? (0, students.length)
        : classPrayerCount(ref, [for (final s in students) s.id], prayer);

    return JzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/app/org/teacher/class/${schoolClass.id}'),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schoolClass.name, style: t.titleMedium),
                    Text(
                      '${students.length} students${section == null ? '' : ' · $section'}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              const JzChevron(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(activeLabel, style: t.bodySmall),
              const SizedBox(width: 10),
              Expanded(child: JzBar(value: total == 0 ? 0 : done / total)),
              const SizedBox(width: 10),
              Text('$done/$total', style: t.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
