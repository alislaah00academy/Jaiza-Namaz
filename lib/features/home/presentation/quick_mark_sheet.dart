import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/widgets/jaiza_lottie.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';

/// Bottom-nav center button: mark the currently-active Fard prayer without
/// leaving Home. If no Fard window is active right now, shows the upcoming
/// one instead (informational only — marking before a prayer starts
/// wouldn't make sense).
Future<void> showQuickMarkSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _QuickMarkSheet(),
  );
}

class _QuickMarkSheet extends ConsumerStatefulWidget {
  const _QuickMarkSheet();

  @override
  ConsumerState<_QuickMarkSheet> createState() => _QuickMarkSheetState();
}

class _QuickMarkSheetState extends ConsumerState<_QuickMarkSheet> {
  bool _celebrating = false;

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(currentPrayerCardProvider);
    final scheme = Theme.of(context).colorScheme;

    if (_celebrating) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const JaizaLottie(
                      asset: JaizaAnims.celebration,
                      width: 220,
                      height: 120,
                      repeat: false,
                    ),
                    AnimatedCheck(color: scheme.primary, size: 72),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'MashaAllah — prayer recorded',
                style: Theme.of(context).textTheme.titleMedium,
              ).jaizaPop(delay: JaizaMotion.fast),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: cardAsync.when(
          data: (data) {
            final activeKey = data.status.activePrayerKey;
            if (activeKey == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bedtime_outlined, size: 36, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'No prayer is active right now.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next: ${data.status.nextLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }
            final prayerName = PrayerNameX.fromFirestore(activeKey);
            if (prayerName == null) return const SizedBox.shrink();
            final window = data.today.fardWindows.firstWhere(
              (w) => w.key == activeKey,
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  window.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mark this prayer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _mark(prayerName, PrayerStatus.missed),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Missed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _mark(prayerName, PrayerStatus.completed),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Completed'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => const Text('Prayer times unavailable right now.'),
        ),
      ),
    );
  }

  Future<void> _mark(PrayerName prayerName, PrayerStatus status) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await ref
        .read(prayerRepositoryProvider)
        .upsertPrayer(
          userId: uid,
          prayerName: prayerName,
          type: PrayerType.fard,
          status: status,
        );
    if (!mounted) return;
    if (status == PrayerStatus.completed) {
      // Brief celebration before dismissing.
      setState(() => _celebrating = true);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }
}
