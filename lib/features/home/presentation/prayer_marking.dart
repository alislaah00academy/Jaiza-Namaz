import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaiza_core/jaiza_core.dart' show SubjectRef;

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Checkbox handler shared by Today, Records and Nawafil. Ticking records
/// the prayer as prayed; un-ticking asks first, then records it as missed
/// (the repository has no "clear" state).
Future<void> togglePrayer(
  BuildContext context,
  WidgetRef ref, {
  required PrayerName name,
  required String label,
  required PrayerType type,
  required bool currentlyDone,
  DateTime? at,

  /// Whose prayer this is — a child's or student's id when marking for
  /// someone else (defaults to the signed-in user when null).
  String? personId,

  /// Required alongside [personId] when it's a student, not a child.
  bool personIsStudent = false,
}) async {
  final me = ref.read(currentUserProvider)?.uid;
  if (me == null) return;
  final subject = _subjectFor(personId, personIsStudent, me);
  if (currentlyDone) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.unmarkTitle(label)),
        content: Text(ctx.l10n.unmarkBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.unmarkButton),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  try {
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          subject: subject,
          markedBy: me,
          prayerName: name,
          type: type,
          status: currentlyDone ? PrayerStatus.missed : PrayerStatus.completed,
          at: at,
        );
    if (context.mounted && !currentlyDone && type == PrayerType.fard) {
      AppSnackBar.success(context, context.l10n.namazMarkedSuccess);
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, context.l10n.errorSaveFailed);
    }
  }
}

/// "Missed · Add to Qaza" — records the prayer as missed so it is kept in
/// the Qaza list with its date.
Future<void> addMissedToQaza(
  BuildContext context,
  WidgetRef ref, {
  required PrayerName name,
  required String label,
  DateTime? at,
  String? personId,
  bool personIsStudent = false,
}) async {
  final me = ref.read(currentUserProvider)?.uid;
  if (me == null) return;
  final subject = _subjectFor(personId, personIsStudent, me);
  try {
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          subject: subject,
          markedBy: me,
          prayerName: name,
          type: PrayerType.fard,
          status: PrayerStatus.missed,
          at: at,
        );
    if (context.mounted) {
      AppSnackBar.success(
        context,
        personId == null
            ? context.l10n.addedToYourQaza(label)
            : context.l10n.addedToQaza(label),
      );
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, context.l10n.errorSaveFailed);
    }
  }
}

SubjectRef _subjectFor(String? personId, bool personIsStudent, String me) {
  if (personId == null) return SubjectRef.self(me);
  return personIsStudent
      ? SubjectRef.student(personId)
      : SubjectRef.child(personId);
}

/// The inline "Missed · Add to Qaza" sub line.
class MissedAddToQaza extends StatelessWidget {
  const MissedAddToQaza({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: c.error,
      fontWeight: FontWeight.w600,
    );
    return GestureDetector(
      onTap: onAdd,
      child: Text.rich(
        TextSpan(
          text: context.l10n.missedDot,
          children: [
            TextSpan(
              text: context.l10n.addToQaza,
              style: TextStyle(
                color: c.primary,
                decoration: TextDecoration.underline,
                decorationColor: c.primary,
              ),
            ),
          ],
        ),
        style: style,
      ),
    );
  }
}
