import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Backlog input, suggested daily goal, and progress toward Qaza.
class QazaScreen extends ConsumerStatefulWidget {
  const QazaScreen({super.key});

  @override
  ConsumerState<QazaScreen> createState() => _QazaScreenState();
}

class _QazaScreenState extends ConsumerState<QazaScreen> {
  final _y = TextEditingController();
  final _m = TextEditingController();
  final _d = TextEditingController();
  int _completedAll = 0;
  int _today = 0;
  bool _loadingStats = true;
  bool _seededFields = false;

  @override
  void dispose() {
    _y.dispose();
    _m.dispose();
    _d.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid != null) _loadStats(uid);
    });
  }

  Future<void> _loadStats(String uid) async {
    if (!mounted) return;
    setState(() => _loadingStats = true);
    final repo = ref.read(prayerRepositoryProvider);
    final c = await repo.countCompletedQaza(uid);
    final t = await repo.countTodayQaza(uid);
    if (mounted) {
      setState(() {
        _completedAll = c;
        _today = t;
        _loadingStats = false;
      });
    }
  }

  int _suggestedDaily(int estimatedRemaining) {
    if (estimatedRemaining <= 0) return 1;
    final g = (estimatedRemaining / 30).ceil();
    return g.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;

    if (uid == null) {
      return const Center(child: Text('Sign in required'));
    }

    if (appUser != null && !_seededFields) {
      _y.text = '${appUser.qazaBacklogYears}';
      _m.text = '${appUser.qazaBacklogMonths}';
      _d.text = '${appUser.qazaBacklogDays}';
      _seededFields = true;
    }

    final name = appUser?.name ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'User';
    final est = appUser?.estimatedQazaPrayers ?? 0;
    final remaining = (est - _completedAll).clamp(0, 1 << 30);
    final dailyTarget = appUser?.qazaDailyTarget ?? 1;
    final suggested = _suggestedDaily(remaining);
    final todayProgress = dailyTarget == 0
        ? 0.0
        : (_today / dailyTarget).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Missed prayers (estimate)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Rough estimate: 5 Fard prayers per day × duration you enter. '
          'Adjust numbers to match your situation.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _y,
                decoration: const InputDecoration(labelText: 'Years'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _m,
                decoration: const InputDecoration(labelText: 'Months'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _d,
                decoration: const InputDecoration(labelText: 'Days'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            final ys = int.tryParse(_y.text) ?? 0;
            final ms = int.tryParse(_m.text) ?? 0;
            final ds = int.tryParse(_d.text) ?? 0;
            final estTotal = _estimateTotal(ys, ms, ds);
            final rem = (estTotal - _completedAll).clamp(0, 1 << 30);
            final sug = _suggestedDaily(rem);
            try {
              await ref.read(userRepositoryProvider).updateProfile(
                    uid: uid,
                    name: name,
                    qazaBacklogYears: ys,
                    qazaBacklogMonths: ms,
                    qazaBacklogDays: ds,
                    qazaDailyTarget: sug,
                  );
              if (context.mounted) {
                AppSnackBar.success(context, 'Backlog saved.');
                await _loadStats(uid);
              }
            } catch (_) {
              if (context.mounted) {
                AppSnackBar.error(context, 'Could not save.');
              }
            }
          },
          child: const Text('Save backlog'),
        ),
        if (_loadingStats)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 24),
        Text(
          'Suggested daily Qaza goal: $suggested',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text('Your current target: $dailyTarget'),
        const SizedBox(height: 16),
        Text(
          'Progress',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('Estimated total to make up: $est'),
        Text('Completed (logged): $_completedAll'),
        Text('Remaining (estimate): $remaining'),
        const SizedBox(height: 8),
        Text("Today's Qaza: $_today / $dailyTarget"),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: todayProgress, minHeight: 10),
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: _loadingStats
              ? null
              : () async {
                  try {
                    await ref.read(prayerRepositoryProvider).upsertPrayer(
                          userId: uid,
                          prayerName: PrayerName.qazaGeneric,
                          type: PrayerType.qaza,
                          status: PrayerStatus.completed,
                        );
                    if (context.mounted) {
                      AppSnackBar.success(
                        context,
                        'Qaza prayer recorded. May Allah accept it.',
                      );
                      await _loadStats(uid);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      AppSnackBar.error(context, 'Could not save.');
                    }
                  }
                },
          child: const Text('Mark one Qaza completed'),
        ),
      ],
    );
  }

  int _estimateTotal(int y, int m, int d) {
    return y * 365 * 5 + m * 30 * 5 + d * 5;
  }
}
