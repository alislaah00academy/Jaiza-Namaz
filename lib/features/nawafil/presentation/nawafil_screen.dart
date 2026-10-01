import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../home/presentation/prayer_marking.dart';
import '../../../core/l10n/l10n.dart';

/// Turns Nawafil tracking on or off (`users/{uid}.nawafilEnabled`).
Future<void> setNawafilEnabled(
  BuildContext context,
  WidgetRef ref,
  bool enabled,
) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;
  final name =
      ref.read(appUserStreamProvider).value?.name ??
      FirebaseAuth.instance.currentUser?.displayName ??
      'User';
  try {
    await ref
        .read(userRepositoryProvider)
        .updateProfile(uid: uid, name: name, nawafilEnabled: enabled);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, context.l10n.couldNotUpdatePreference);
    }
  }
}

/// Today's Nawafil — same tick-to-mark pattern as the Fard list.
class NawafilScreen extends ConsumerWidget {
  const NawafilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final enabled =
        ref.watch(appUserStreamProvider).value?.nawafilEnabled ?? false;
    final logs = ref.watch(todayNawafilProvider).value ?? const [];

    if (!enabled) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          JzCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const JzAvatar(icon: Icons.front_hand_outlined, size: 56),
                const SizedBox(height: 14),
                Text(context.l10n.nawafilTrackingIsOff, style: t.titleMedium),
                const SizedBox(height: 6),
                Text(
                  context.l10n.nawafilTurnOnBody,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setNawafilEnabled(context, ref, true),
                  child: Text(context.l10n.turnOnNawafil),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          child: Column(
            children: [
              for (var i = 0; i < kNawafilDefs.length; i++)
                Builder(
                  builder: (context) {
                    final def = kNawafilDefs[i];
                    final done = logs.any(
                      (l) =>
                          l.prayerName == def.name &&
                          l.status == PrayerStatus.completed,
                    );
                    return JzPrayerRow(
                      name: def.label(context.l10n),
                      checked: done,
                      showDivider: i < kNawafilDefs.length - 1,
                      onToggle: () => togglePrayer(
                        context,
                        ref,
                        name: def.name,
                        label: def.label(context.l10n),
                        type: PrayerType.nawafil,
                        currentlyDone: done,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
          child: Text(context.l10n.nawafilTurnOffHint, style: t.bodySmall),
        ),
      ],
    );
  }
}
