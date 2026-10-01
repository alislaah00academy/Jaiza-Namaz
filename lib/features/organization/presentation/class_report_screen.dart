import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../parent/data/family_data.dart';
import 'class_mark_screen.dart' show LetterAvatarLike;
import '../../../core/l10n/l10n.dart';

enum _Range { week, month }

/// A class's attendance report — this week or this month, class average
/// and a per-student ranked bar list.
class ClassReportScreen extends ConsumerStatefulWidget {
  const ClassReportScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<ClassReportScreen> createState() => _ClassReportScreenState();
}

class _ClassReportScreenState extends ConsumerState<ClassReportScreen> {
  _Range _range = _Range.month;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final appUser = ref.watch(appUserStreamProvider).value;
    final orgId = appUser?.orgId;
    final students = orgId == null
        ? const []
        : ref
                  .watch(
                    studentsForClassProvider((
                      orgId: orgId,
                      classId: widget.classId,
                    )),
                  )
                  .value ??
              const [];

    final now = DateTime.now();
    final start = _range == _Range.week
        ? now.subtract(const Duration(days: 6))
        : DateTime(now.year, now.month, 1);
    final days =
        now.difference(DateTime(start.year, start.month, start.day)).inDays + 1;
    final possiblePerStudent = days * kFardPrayerDefs.length;

    final rows = <(String, int, double)>[];
    var totalDone = 0;
    for (final s in students) {
      final logs =
          ref.watch(personFardLogsProvider(s.id)).value ?? const [];
      final done = logs.where((l) {
        final d = l.dateTime.toLocal();
        final day = DateTime(d.year, d.month, d.day);
        return !day.isBefore(DateTime(start.year, start.month, start.day)) &&
            !day.isAfter(now) &&
            l.status == PrayerStatus.completed &&
            kFardPrayerDefs.any((f) => f.name == l.prayerName);
      }).length;
      totalDone += done;
      rows.add((
        s.name,
        done,
        possiblePerStudent == 0 ? 0 : done / possiblePerStudent,
      ));
    }
    rows.sort((a, b) => b.$3.compareTo(a.$3));
    final totalPossible = possiblePerStudent * students.length;
    final avgPct = totalPossible == 0
        ? 0
        : (totalDone * 100 / totalPossible).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzSegmented<_Range>(
          options: {
            _Range.week: context.l10n.thisWeek,
            _Range.month: context.l10n.thisMonth,
          },
          selected: _range,
          onChanged: (r) => setState(() => _range = r),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(context.l10n.classAverage, style: t.titleMedium),
                  ),
                  Text(context.l10n.percent(avgPct), style: t.headlineSmall),
                ],
              ),
              const SizedBox(height: 10),
              JzBar(value: avgPct / 100, height: 8),
              const SizedBox(height: 8),
              Text(
                context.l10n.classReportSummary(
                  context.l10n.studentsCount(students.length),
                  DateFormat('MMMM y', context.l10n.localeName).format(now),
                  totalDone,
                  totalPossible,
                ),
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JzSectionLabel(context.l10n.byStudent),
        JzCard(
          child: Column(
            children: [
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.l10n.noStudentsYet, style: t.bodyMedium),
                )
              else
                for (var i = 0; i < rows.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: i < rows.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        LetterAvatarLike(rows[i].$1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rows[i].$1, style: t.titleSmall),
                              const SizedBox(height: 4),
                              JzBar(value: rows[i].$3),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.percent((rows[i].$3 * 100).round()),
                          style: t.titleSmall,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => AppSnackBar.success(
                  context,
                  context.l10n.sharingComingSoon,
                ),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: Text(context.l10n.shareReport),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  AppSnackBar.success(context, context.l10n.pdfComingSoon),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(context.l10n.pdfButton),
            ),
          ],
        ),
      ],
    );
  }
}
