import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

class NawafilScreen extends ConsumerStatefulWidget {
  const NawafilScreen({super.key});

  @override
  ConsumerState<NawafilScreen> createState() => _NawafilScreenState();
}

class _NawafilScreenState extends ConsumerState<NawafilScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final user = ref.watch(appUserStreamProvider);

    if (uid == null) {
      return const Center(child: Text('Sign in required'));
    }

    return user.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (appUser) {
        final enabled = appUser?.nawafilEnabled ?? false;
        final displayName = appUser?.name ??
            FirebaseAuth.instance.currentUser?.displayName ??
            'User';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Enable Nawafil tracking'),
              subtitle: const Text(
                'Turn on to log optional prayers and work toward badges.',
              ),
              value: enabled,
              onChanged: _busy
                  ? null
                  : (v) async {
                      setState(() => _busy = true);
                      try {
                        await ref.read(userRepositoryProvider).updateProfile(
                              uid: uid,
                              name: displayName,
                              nawafilEnabled: v,
                            );
                      } catch (_) {
                        if (context.mounted) {
                          AppSnackBar.error(
                            context,
                            'Could not update preference.',
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => _busy = false);
                      }
                    },
            ),
            const Divider(),
            if (!enabled)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Enable tracking above to record nawafil and grow your rewards.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              ref.watch(todayNawafilProvider).when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('$e'),
                    data: (logs) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (logs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                AppStrings.noPrayersYet,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ...kNawafilDefs.map((def) {
                            final done = logs.any(
                              (l) =>
                                  l.prayerName == def.name &&
                                  l.status == PrayerStatus.completed,
                            );
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(def.label),
                                trailing: done
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : FilledButton(
                                        onPressed: () => _mark(context, def.name),
                                        child: const Text('Mark'),
                                      ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  Future<void> _mark(BuildContext context, PrayerName name) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref.read(prayerRepositoryProvider).upsertPrayer(
            userId: uid,
            prayerName: name,
            type: PrayerType.nawafil,
            status: PrayerStatus.completed,
          );
      if (context.mounted) {
        AppSnackBar.success(context, AppStrings.namazMarkedSuccess);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not save.');
      }
    }
  }
}
