import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/jz_ui.dart';
import '../../qaza/data/qaza_plan.dart';
import '../../qaza/presentation/qaza_widgets.dart';
import '../data/family_data.dart';

/// A child's Qaza dashboard — same shape as the user's own, minus the
/// estimate row (children have no estimate backend yet).
class ChildQazaScreen extends ConsumerWidget {
  const ChildQazaScreen({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final overview = ref.watch(childQazaOverviewProvider(childId));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Jaiza has been counting missed prayers for you since the day you '
          'installed it. If you also have Qaza from before that, add an '
          'estimate once and both are kept in one list.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 14),
        QazaTotalCard(overview: overview, allowEstimate: false),
        const SizedBox(height: 14),
        const JzSectionLabel('By prayer'),
        for (final p in kQazaPrayerNames)
          QazaPrayerCard(summary: overview.byPrayer[p]!, personId: childId),
      ],
    );
  }
}
