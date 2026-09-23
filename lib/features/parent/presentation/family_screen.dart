import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/family_data.dart';
import 'family_widgets.dart';

/// Family: every child's today/week progress, streak and Qaza — the "See
/// all" destination from the parent's Today card.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddChildSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add a child'),
      ),
      body: children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const JzAvatar(
                      icon: Icons.family_restroom_outlined,
                      size: 64,
                      iconSize: 32,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No children added yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add a child to mark and track their Salah.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                for (final k in children) _ChildCard(childId: k.id, name: k.name),
              ],
            ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.childId, required this.name});

  final String childId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final extra = ref.watch(childExtrasProvider)[childId];
    final logs = ref.watch(personFardLogsProvider(childId)).valueOrNull ?? const [];
    final total = kFardPrayerDefs.length;
    final today = fardDoneOn(logs, DateTime.now());
    final week = fardDoneThisWeek(logs);
    final (streak, _) = fardStreak(logs);
    final qaza = ref.watch(childQazaOverviewProvider(childId));

    Widget bar(String label, double value, String trailing) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(label, style: t.bodySmall)),
          Expanded(child: JzBar(value: value)),
          const SizedBox(width: 10),
          Text(trailing, style: t.titleSmall),
        ],
      ),
    );

    return JzCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      onTap: () {
        ref.read(selectedChildIdProvider.notifier).state = childId;
        context.go('/app/home');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LetterAvatar(name, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: t.titleMedium),
                    if (extra?.label.isNotEmpty ?? false)
                      Text(extra!.label, style: t.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 4),
          bar('Today', today / total, '$today/$total'),
          bar('Week', week / (total * 7), '$week/${total * 7}'),
          const JzDivider(top: 12, bottom: 8),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 18,
                color: c.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Streak', style: t.bodySmall)),
              JzChip('$streak ${streak == 1 ? 'day' : 'days'}'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.history_edu_outlined, size: 18, color: c.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('Qaza to make up', style: t.bodySmall)),
                JzChip(
                  qaza.remaining == 0 ? 'None' : '${qaza.remaining}',
                  gold: qaza.remaining == 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
