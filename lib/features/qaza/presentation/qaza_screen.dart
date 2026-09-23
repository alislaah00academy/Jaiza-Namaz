import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/qaza_plan.dart';
import '../data/qaza_tracker.dart';
import 'qaza_widgets.dart';

/// `/app/qaza`. First visit: one explainer ending in a choice (enter an
/// estimate, or let Jaiza count from today). After that: the dashboard that
/// carries both sources.
class QazaScreen extends ConsumerWidget {
  const QazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introDone = ref.watch(qazaIntroDoneProvider);
    final overview = ref.watch(qazaOverviewProvider);
    if (!introDone && !overview.hasEstimate) return const _QazaIntro();
    return _QazaDashboard(overview: overview);
  }
}

class _QazaIntro extends ConsumerWidget {
  const _QazaIntro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    Widget option({
      required IconData icon,
      required JzAvatarTone tone,
      required String title,
      required String body,
      required VoidCallback onTap,
    }) => JzCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          JzAvatar(icon: icon, size: 44, iconSize: 22, tone: tone),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: c.tertiary),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'CALCULATE YOUR\n',
            children: [
              TextSpan(
                text: 'QAZA PRAYERS',
                style: TextStyle(color: c.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Divider(color: c.tertiary.withValues(alpha: 0.4))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: c.tertiary,
              ),
            ),
            Expanded(child: Divider(color: c.tertiary.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Work out the prayers you missed from the time you reached Bulugh '
          '(puberty) until today.',
          textAlign: TextAlign.center,
          style: t.bodyMedium,
        ),
        const SizedBox(height: 24),
        const JaizaFlourishDivider(label: 'CHOOSE HOW TO START'),
        const SizedBox(height: 18),
        option(
          icon: Icons.edit_note_rounded,
          tone: JzAvatarTone.primary,
          title: 'I will enter my own estimate',
          body:
              'Type how much you missed before Jaiza — the same figure for all '
              'five prayers, or each prayer separately.',
          onTap: () => context.push('/app/qaza/estimate'),
        ),
        option(
          icon: Icons.auto_mode_rounded,
          tone: JzAvatarTone.secondary,
          title: 'Let Jaiza count from today',
          body:
              'From now on, every prayer you do not mark becomes Qaza by '
              'itself, with its date. Nothing to type — and you can still add '
              'an estimate later.',
          onTap: () => ref.read(qazaIntroDoneProvider.notifier).set(true),
        ),
        const SizedBox(height: 4),
        const JzImportantNote(),
      ],
    );
  }
}

class _QazaDashboard extends ConsumerWidget {
  const _QazaDashboard({required this.overview});

  final QazaOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          overview.hasEstimate
              ? 'Everything you still owe, in one place — what Jaiza counted '
                    'for you since install, plus the backlog you estimated. '
                    'Tap any prayer to mark some as prayed.'
              : 'Jaiza has been counting missed prayers for you since the day '
                    'you installed it. If you also have Qaza from before that, '
                    'add an estimate once and both are kept in one list.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 14),
        QazaTotalCard(overview: overview),
        const SizedBox(height: 14),
        if (overview.hasEstimate) ...[
          JzCard(
            padding: const EdgeInsets.all(18),
            onTap: () => context.push('/app/qaza/plan'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Daily goal', style: t.titleMedium)),
                    JzChip('${overview.dailyGoal} a day', gold: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: 'At this pace you will finish in about ',
                    children: [
                      TextSpan(
                        text: qazaDurationLabel(overview.daysToFinish),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  style: t.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: JzBar(
                        value: overview.total == 0
                            ? 0
                            : overview.completed / overview.total,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${jzCount(overview.completed)} done',
                      style: t.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        const JzSectionLabel('By prayer'),
        for (final p in kQazaPrayerNames)
          QazaPrayerCard(summary: overview.byPrayer[p]!),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => showQazaHowItWorks(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline_rounded, size: 18, color: c.primary),
                const SizedBox(width: 8),
                Text('How Qaza works in Jaiza', style: t.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
