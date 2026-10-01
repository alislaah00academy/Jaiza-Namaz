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
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/prayer_labels.dart';

/// The "Classes" tab — an org admin's dashboard, or a teacher's class list,
/// decided by [AppUser.orgMemberRole]. Same tab position in the shell for
/// both, per the design ("the same shell").
class OrgClassesTab extends ConsumerWidget {
  const OrgClassesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).value;
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
    final org = ref.watch(myOrgProvider).value;
    if (org == null) {
      return Center(child: Text(context.l10n.organizationNotFound));
    }
    final teachers =
        ref.watch(allTeachersForOrgProvider(org.id)).value ?? const [];
    final classes =
        ref.watch(allClassesForOrgProvider(org.id)).value ?? const [];
    final sections = ref.watch(classSectionsProvider);
    var totalStudents = 0;
    var todaySum = 0.0;
    for (final c in classes) {
      final students =
          ref
              .watch(studentsForClassProvider((orgId: org.id, classId: c.id)))
              .value ??
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
                              label: context.l10n.statTeachers,
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              value: '${classes.length}',
                              label: context.l10n.titleClasses,
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              value: '$totalStudents',
                              label: context.l10n.statStudents,
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
                            context.l10n.todayAcrossMadrasa,
                            style: t.bodyMedium,
                          ),
                        ),
                        Text(context.l10n.percent(todayPct), style: t.titleSmall),
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
                  Expanded(child: JzSectionLabel(context.l10n.statTeachers)),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () =>
                        showInviteTeacherSheet(context, ref, org.id),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label: Text(context.l10n.inviteTeacher),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (teachers.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.l10n.noTeachersYet,
                    style: t.bodyMedium,
                  ),
                )
              else
                for (final teacher in teachers)
                  _TeacherRow(org: org, teacher: teacher, classes: classes),
              const SizedBox(height: 18),
              JzSectionLabel(context.l10n.allClasses),
              JzCard(
                child: Column(
                  children: [
                    if (classes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(context.l10n.noClassesYet, style: t.bodyMedium),
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
                                    .value ??
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
                                  context.l10n.dotJoin(
                                    sections[c.id] ??
                                        teacherName ??
                                        context.l10n.unassigned,
                                    '${students.length}',
                                  ),
                              trailing: Text(
                                pct == null ? '—' : context.l10n.percent(pct),
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
              .value
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
                  context.l10n.classesStudents(
                    context.l10n.classesCount(mine.length),
                    context.l10n.studentsCount(students),
                  ),
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
    final appUser = ref.watch(appUserStreamProvider).value;
    final orgId = appUser?.orgId;
    final membership = ref.watch(myTeacherMembershipProvider);

    if (uid == null || orgId == null) {
      return Center(child: Text(context.l10n.notAttachedToOrg));
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
              Text(
                context.l10n.accessRemoved,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final classes =
        ref.watch(classesForTeacherProvider).value ?? const [];
    final sections = ref.watch(classSectionsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        JzPageTitle(context.l10n.titleClasses),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            context.l10n.residentialStudentsNote,
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
              label: Text(context.l10n.newClass),
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
                    context.l10n.noClassesCreateOne,
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
            .value ??
        const [];
    final schedule = ref.watch(currentPrayerCardProvider).value;
    final activeKey =
        schedule?.status.activePrayerKey ?? schedule?.status.nextKey;
    final activeLabel =
        (schedule?.status.activePrayer ??
                schedule?.status.nextPrayer ??
                PrayerName.fajr)
            .label(context.l10n);
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
                      section == null
                          ? context.l10n.studentsCount(students.length)
                          : context.l10n.dotJoin(
                              context.l10n.studentsCount(students.length),
                              section!,
                            ),
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
              Text(context.l10n.doneSlashTotal(done, total), style: t.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
