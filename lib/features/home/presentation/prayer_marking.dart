import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/l10n/app_strings.dart';
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
}) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;
  if (currentlyDone) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unmark $label?'),
        content: const Text('It will be recorded as not prayed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unmark'),
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
        );
    if (context.mounted && !currentlyDone && type == PrayerType.fard) {
      AppSnackBar.success(context, AppStrings.namazMarkedSuccess);
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, 'Could not save. Try again.');
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
}) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;
  try {
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          userId: uid,
          prayerName: name,
          type: PrayerType.fard,
          status: PrayerStatus.missed,
          at: at,
        );
    if (context.mounted) {
      AppSnackBar.success(context, '$label added to your Qaza list.');
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, 'Could not save. Try again.');
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
          text: 'Missed · ',
          children: [
            TextSpan(
              text: 'Add to Qaza',
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
