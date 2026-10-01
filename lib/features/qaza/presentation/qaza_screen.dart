import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/qaza_plan.dart';
import '../data/qaza_tracker.dart';
import 'qaza_widgets.dart';
import '../../../core/l10n/l10n.dart';

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
            text: context.l10n.qazaCalculateYour,
            children: [
              TextSpan(
                text: context.l10n.qazaPrayersCaps,
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
          context.l10n.qazaIntroBody,
          textAlign: TextAlign.center,
          style: t.bodyMedium,
        ),
        const SizedBox(height: 24),
        JaizaFlourishDivider(label: context.l10n.chooseHowToStart),
        const SizedBox(height: 18),
        option(
          icon: Icons.edit_note_rounded,
          tone: JzAvatarTone.primary,
          title: context.l10n.qazaOptionEstimateTitle,
          body: context.l10n.qazaOptionEstimateBody,
          onTap: () => context.push('/app/qaza/estimate'),
        ),
        option(
          icon: Icons.auto_mode_rounded,
          tone: JzAvatarTone.secondary,
          title: context.l10n.qazaOptionCountTitle,
          body: context.l10n.qazaOptionCountBody,
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
              ? context.l10n.qazaDashboardWithEstimate
              : context.l10n.qazaDashboardNoEstimate,
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
                    Expanded(
                      child: Text(context.l10n.dailyGoal, style: t.titleMedium),
                    ),
                    JzChip(context.l10n.perDay(overview.dailyGoal), gold: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: context.l10n.qazaPacePrefix,
                    children: [
                      TextSpan(
                        text: qazaDurationLabel(
                          overview.daysToFinish,
                          context.l10n,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: context.l10n.qazaPaceSuffix),
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
                      context.l10n.countDone(jzCount(overview.completed)),
                      style: t.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        JzSectionLabel(context.l10n.byPrayer),
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
                Text(context.l10n.qazaHowTitle, style: t.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
