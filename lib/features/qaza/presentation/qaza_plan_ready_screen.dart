import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/qaza_tracker.dart';

/// "Add past Qaza" — shown after the estimate is saved: confirmation, a
/// daily goal (`qazaDailyTarget`) and the daily reminder toggle.
class QazaPlanReadyScreen extends ConsumerStatefulWidget {
  const QazaPlanReadyScreen({super.key});

  @override
  ConsumerState<QazaPlanReadyScreen> createState() =>
      _QazaPlanReadyScreenState();
}

class _QazaPlanReadyScreenState extends ConsumerState<QazaPlanReadyScreen> {
  int? _goal;
  bool _saving = false;

  Future<void> _done() async {
    final uid = ref.read(currentUserProvider)?.uid;
    final user = ref.read(appUserStreamProvider).valueOrNull;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      if (_goal != null && _goal != user?.qazaDailyTarget) {
        await ref
            .read(userRepositoryProvider)
            .updateProfile(
              uid: uid,
              name:
                  user?.name ??
                  FirebaseAuth.instance.currentUser?.displayName ??
                  'User',
              qazaDailyTarget: _goal,
            );
      }
      if (mounted) context.go('/app/qaza');
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final overview = ref.watch(qazaOverviewProvider);
    final user = ref.watch(appUserStreamProvider).valueOrNull;
    final goal = _goal ?? (user?.qazaDailyTarget ?? 1).clamp(1, 999);
    final days = goal <= 0 ? 0 : (overview.remaining / goal).ceil();
    final finish = DateTime.now().add(Duration(days: days));
    final remind = ref.watch(qazaRemindDailyProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const JzEmblem(icon: Icons.check_rounded, size: 72),
              const SizedBox(height: 14),
              Text('Your estimate is saved', style: t.headlineSmall),
              const SizedBox(height: 6),
              Text(
                '${jzCount(overview.estimateTotal)} prayers from before Jaiza, '
                'plus the ${jzCount(overview.trackedTotal)} counted since you '
                'installed it.',
                textAlign: TextAlign.center,
                style: t.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set a daily goal', style: t.titleMedium),
              const SizedBox(height: 2),
              Text(
                'How many Qaza will you pray each day? Start small — you can '
                'change this whenever you like.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: JzStepper(
                      value: goal,
                      onChanged: (v) => setState(() => _goal = v),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('a day', style: t.bodyLarge),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.tertiaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: c.tertiary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'At $goal a day you will finish in about ',
                          children: [
                            TextSpan(
                              text: qazaDurationLabel(days),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' — around ${DateFormat('MMMM y').format(finish)}.',
                            ),
                          ],
                        ),
                        style: t.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(16),
          child: JzSwitchRow(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: c.primary,
            ),
            title: 'Remind me daily',
            subtitle: "One nudge after Isha if the day's Qaza is not done",
            value: remind,
            onChanged: (v) => ref.read(qazaRemindDailyProvider.notifier).set(v),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _saving ? null : _done,
          child: const Text('Done'),
        ),
      ],
    );
  }
}
