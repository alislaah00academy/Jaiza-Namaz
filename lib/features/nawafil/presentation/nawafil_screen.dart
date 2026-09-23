import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../home/presentation/prayer_marking.dart';

/// Turns Nawafil tracking on or off (`users/{uid}.nawafilEnabled`).
Future<void> setNawafilEnabled(
  BuildContext context,
  WidgetRef ref,
  bool enabled,
) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;
  final name =
      ref.read(appUserStreamProvider).valueOrNull?.name ??
      FirebaseAuth.instance.currentUser?.displayName ??
      'User';
  try {
    await ref
        .read(userRepositoryProvider)
        .updateProfile(uid: uid, name: name, nawafilEnabled: enabled);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.error(context, 'Could not update preference.');
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
        ref.watch(appUserStreamProvider).valueOrNull?.nawafilEnabled ?? false;
    final logs = ref.watch(todayNawafilProvider).valueOrNull ?? const [];

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
                Text('Nawafil tracking is off', style: t.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Turn it on to tick off your optional prayers each day.',
                  textAlign: TextAlign.center,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setNawafilEnabled(context, ref, true),
                  child: const Text('Turn on Nawafil'),
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
                      name: def.label,
                      checked: done,
                      showDivider: i < kNawafilDefs.length - 1,
                      onToggle: () => togglePrayer(
                        context,
                        ref,
                        name: def.name,
                        label: def.label,
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
          child: Text(
            'To stop tracking Nawafil, turn it off in More → Nawafil.',
            style: t.bodySmall,
          ),
        ),
      ],
    );
  }
}
