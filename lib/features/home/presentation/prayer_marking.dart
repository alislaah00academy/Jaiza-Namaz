import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Whose prayer this is — a child's id when a parent marks for them.
  String? personId,
}) async {
  final me = ref.read(currentUserProvider)?.uid;
  if (me == null) return;
  final uid = personId ?? me;
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
          userId: uid,
          prayerName: name,
          type: type,
          status: currentlyDone ? PrayerStatus.missed : PrayerStatus.completed,
          at: at,
          ownerUid: uid == me ? null : me,
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
}) async {
  final me = ref.read(currentUserProvider)?.uid;
  if (me == null) return;
  final uid = personId ?? me;
  try {
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          userId: uid,
          prayerName: name,
          type: PrayerType.fard,
          status: PrayerStatus.missed,
          at: at,
          ownerUid: uid == me ? null : me,
        );
    if (context.mounted) {
      AppSnackBar.success(
        context,
        uid == me
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
