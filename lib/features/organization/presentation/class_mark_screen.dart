import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart' show AnalyticsSubject;
import 'package:go_router/go_router.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/formatters.dart';
import '../../../core/l10n/prayer_labels.dart';

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
            subject: AnalyticsSubject.student,
          );
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.errorSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final appUser = ref.watch(appUserStreamProvider).value;
    final orgId = appUser?.orgId;
    final teacherUid = ref.watch(currentUserProvider)?.uid;
    if (orgId == null || teacherUid == null) {
      return Center(child: Text(context.l10n.notAttachedToOrg));
    }
    final students =
        ref
            .watch(
              studentsForClassProvider((orgId: orgId, classId: widget.classId)),
            )
            .value ??
        const [];
    final schedule = ref.watch(currentPrayerCardProvider).value;
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
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: JzChip(
                            def.label(context.l10n),
                            selected: def.name == prayer,
                            onTap: () => setState(() => _selected = def.name),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.classReport,
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
                                prayer.label(context.l10n),
                                style: t.titleMedium,
                              ),
                              if (window != null && window.isNotEmpty)
                                Text(
                                  context.l10n.timeRange(
                                    formatTime(
                                      window.first.start,
                                      context.l10n,
                                    ),
                                    formatTime(window.first.end, context.l10n),
                                  ),
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
                              TextSpan(
                                text: context.l10n.slashTotal(total),
                                style: t.bodySmall,
                              ),
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
                      label: Text(context.l10n.markAllPresent),
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
                    label: Text(context.l10n.unmarkedFilter),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.l10n.noStudentsAddBelow,
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
                                    .value ??
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
                                subtitle: context.l10n.doneOfTotalToday(
                                  doneToday,
                                  kFardPrayerDefs.length,
                                ),
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
                label: Text(context.l10n.titleAddStudents),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.savedAsYouTap,
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
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
