import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';

/// Mark one prayer at a time for a whole class — a single tap per student,
/// no submit button (the design's "Saved as you tap").
class ClassMarkScreen extends ConsumerStatefulWidget {
  const ClassMarkScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<ClassMarkScreen> createState() => _ClassMarkScreenState();
}

class _ClassMarkScreenState extends ConsumerState<ClassMarkScreen> {
  PrayerName? _selected;
  bool _unmarkedOnly = false;

  Future<void> _mark(String studentId, PrayerName prayer, bool done) async {
    final teacherUid = ref.read(currentUserProvider)?.uid;
    if (teacherUid == null) return;
    try {
      await ref
          .read(prayerRepositoryProvider)
          .upsertPrayer(
            userId: studentId,
            prayerName: prayer,
            type: PrayerType.fard,
            status: done ? PrayerStatus.completed : PrayerStatus.missed,
            ownerUid: teacherUid,
          );
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not save. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    final teacherUid = ref.watch(currentUserProvider)?.uid;
    if (orgId == null || teacherUid == null) {
      return const Center(child: Text('Not attached to an organization yet.'));
    }
    final students =
        ref
            .watch(
              studentsForClassProvider((orgId: orgId, classId: widget.classId)),
            )
            .valueOrNull ??
        const [];
    final schedule = ref.watch(currentPrayerCardProvider).valueOrNull;
    final activeKey =
        schedule?.status.activePrayerKey ?? schedule?.status.nextKey;
    final activeDefault =
        PrayerNameX.fromFirestore(activeKey) ?? PrayerName.fajr;
    final prayer = _selected ?? activeDefault;
    final window = schedule?.today.fardWindows
        .where((w) => w.key == prayer.name)
        .toList();
    final (done, total) = classPrayerCount(ref, [
      for (final s in students) s.id,
    ], prayer);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final def in kFardPrayerDefs)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: JzChip(
                            def.label,
                            selected: def.name == prayer,
                            onTap: () => setState(() => _selected = def.name),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Class report',
                icon: const Icon(Icons.insights_outlined),
                onPressed: () => context.push(
                  '/app/org/teacher/class/${widget.classId}/report',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              JzCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kFardPrayerDefs
                                    .firstWhere((d) => d.name == prayer)
                                    .label,
                                style: t.titleMedium,
                              ),
                              if (window != null && window.isNotEmpty)
                                Text(
                                  '${_fmt(window.first.start)} – ${_fmt(window.first.end)}',
                                  style: t.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: '$done',
                            style: t.headlineSmall,
                            children: [
                              TextSpan(text: ' / $total', style: t.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    JzBar(value: total == 0 ? 0 : done / total),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: students.isEmpty
                          ? null
                          : () async {
                              for (final s in students) {
                                await _mark(s.id, prayer, true);
                              }
                            },
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Mark all present'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _unmarkedOnly = !_unmarkedOnly),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _unmarkedOnly
                          ? c.primaryContainer.withValues(alpha: 0.4)
                          : null,
                    ),
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: const Text('Unmarked'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No students yet. Add some below.',
                    style: t.bodyMedium,
                  ),
                )
              else
                JzCard(
                  child: Column(
                    children: [
                      for (final s in students)
                        Builder(
                          builder: (context) {
                            final map =
                                ref
                                    .watch(studentTodayFardMapProvider(s.id))
                                    .valueOrNull ??
                                const {};
                            final markedThis =
                                map[prayer]?.status == PrayerStatus.completed;
                            if (_unmarkedOnly && markedThis) {
                              return const SizedBox.shrink();
                            }
                            final doneToday = kFardPrayerDefs
                                .where(
                                  (d) =>
                                      map[d.name]?.status ==
                                      PrayerStatus.completed,
                                )
                                .length;
                            return Container(
                              decoration: BoxDecoration(
                                color: markedThis
                                    ? c.primaryContainer.withValues(alpha: 0.22)
                                    : null,
                                border: Border(
                                  bottom: BorderSide(color: c.outlineVariant),
                                ),
                              ),
                              child: JzListRow(
                                leading: LetterAvatarLike(s.name),
                                title: s.name,
                                subtitle:
                                    '$doneToday of ${kFardPrayerDefs.length} today',
                                onTap: () => context.push(
                                  '/app/org/teacher/class/${widget.classId}/student/${s.id}',
                                ),
                                trailing: GestureDetector(
                                  onTap: () => _mark(s.id, prayer, !markedThis),
                                  child: JzCheckBox(
                                    checked: markedThis,
                                    size: 32,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/app/org/teacher/class/${widget.classId}/add-students',
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Add students'),
              ),
              const SizedBox(height: 10),
              Text(
                'Saved as you tap — there is no submit button.',
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour % 12 == 0 ? 12 : t.hour % 12}:${t.minute.toString().padLeft(2, '0')} '
      '${t.hour < 12 ? 'AM' : 'PM'}';
}

/// Small round-letter avatar for a roster row (kept local to avoid a
/// cross-feature import for one glyph).
class LetterAvatarLike extends StatelessWidget {
  const LetterAvatarLike(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.secondaryContainer,
      ),
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w700, color: c.secondary),
      ),
    );
  }
}
