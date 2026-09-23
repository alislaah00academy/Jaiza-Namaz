import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/family_data.dart';
import 'family_widgets.dart';

/// Family reminders — parent-only, on-device preferences for the "a child
/// hasn't marked a prayer" nudge (no push-scheduling backend yet).
class FamilyRemindersScreen extends ConsumerWidget {
  const FamilyRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final prefs = ref.watch(familyReminderPrefsProvider);
    final notifier = ref.read(familyReminderPrefsProvider.notifier);
    final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
    final skippedPrayers = prefs.set('skippedPrayers', const {});

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Family reminders', style: t.titleMedium)),
                  const JzChip('New', gold: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'You are nudged only while a prayer can still be prayed — '
                'never after the window has closed.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: c.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const JzAvatar(
                          icon: Icons.mosque_outlined,
                          size: 22,
                          iconSize: 12,
                          tone: JzAvatarTone.gold,
                        ),
                        const SizedBox(width: 8),
                        Text('Jaiza', style: t.labelSmall),
                        const Spacer(),
                        Text('now', style: t.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Bilal hasn’t marked Asr', style: t.titleSmall),
                    Text('30 minutes left in the window', style: t.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What the alert looks like',
                textAlign: TextAlign.center,
                style: t.labelMedium,
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
              Text('When you are alerted', style: t.titleMedium),
              const SizedBox(height: 10),
              JzSwitchRow(
                title: 'Before a window closes',
                subtitle: 'One nudge per prayer, per child',
                value: prefs.flag('beforeClose'),
                onChanged: (v) => notifier.put('beforeClose', v),
              ),
              const JzDivider(),
              Row(
                children: [
                  Expanded(child: Text('How early', style: t.bodyLarge)),
                  PopupMenuButton<int>(
                    initialValue: prefs.number('earlyMinutes', 30),
                    onSelected: (v) => notifier.put('earlyMinutes', v),
                    itemBuilder: (_) => [
                      for (final m in const [10, 15, 20, 30, 45])
                        PopupMenuItem(value: m, child: Text('$m min')),
                    ],
                    child: JzChip('${prefs.number('earlyMinutes', 30)} min', gold: true),
                  ),
                ],
              ),
              const JzDivider(),
              Text('Which prayers', style: t.bodyLarge),
              const SizedBox(height: 2),
              Text(
                'Turn off the ones your children pray at the madrasa — you '
                'won’t be nudged about those.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final def in kFardPrayerDefs)
                    JzChip(
                      def.label,
                      selected: !skippedPrayers.contains(def.name.name),
                      onTap: () {
                        final next = {...skippedPrayers};
                        next.contains(def.name.name)
                            ? next.remove(def.name.name)
                            : next.add(def.name.name);
                        notifier.put('skippedPrayers', next.toList());
                      },
                    ),
                ],
              ),
              const JzDivider(),
              JzSwitchRow(
                title: 'Evening summary',
                subtitle: 'One message after Isha with everyone’s day',
                value: prefs.flag('eveningSummary'),
                onChanged: (v) => notifier.put('eveningSummary', v),
              ),
              if (prefs.flag('eveningSummary')) ...[
                const JzDivider(),
                Row(
                  children: [
                    Expanded(child: Text('Summary time', style: t.bodyLarge)),
                    JzChip('${prefs.number('summaryHour', 21)}:30 PM', gold: true),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Keeping it quiet', style: t.titleMedium),
              const SizedBox(height: 10),
              JzSwitchRow(
                title: 'Quiet hours',
                subtitle: 'No alerts 8:00 AM – 2:00 PM and after 10:00 PM',
                value: prefs.flag('quietHours'),
                onChanged: (v) => notifier.put('quietHours', v),
              ),
              const JzDivider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily limit', style: t.bodyLarge),
                        Text(
                          'Extra nudges are rolled into the evening summary',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    initialValue: prefs.number('dailyLimit', 4),
                    onSelected: (v) => notifier.put('dailyLimit', v),
                    itemBuilder: (_) => [
                      for (final m in const [2, 3, 4, 6, 8])
                        PopupMenuItem(value: m, child: Text('$m a day')),
                    ],
                    child: JzChip(
                      '${prefs.number('dailyLimit', 4)} a day',
                      gold: true,
                    ),
                  ),
                ],
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
              Text('Children', style: t.titleMedium),
              const SizedBox(height: 2),
              Text(
                'Turn a child off to stop every alert about them.',
                style: t.bodySmall,
              ),
              const SizedBox(height: 10),
              if (children.isEmpty)
                Text('Add a child to set this up.', style: t.bodyMedium)
              else
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const JzDivider(),
                  Builder(
                    builder: (context) {
                      final k = children[i];
                      final extra = ref.watch(childExtrasProvider)[k.id];
                      final off = prefs
                          .set('mutedChildren', const {})
                          .contains(k.id);
                      return JzSwitchRow(
                        leading: LetterAvatar(k.name),
                        title: k.name,
                        subtitle: extra?.age == null ? null : '${extra!.age} years',
                        value: !off,
                        onChanged: (v) {
                          final muted = {
                            ...prefs.set('mutedChildren', const {}),
                          };
                          v ? muted.remove(k.id) : muted.add(k.id);
                          notifier.put('mutedChildren', muted.toList());
                        },
                      );
                    },
                  ),
                ],
              const JzDivider(),
              JzSwitchRow(
                title: 'Tell me when a streak breaks',
                subtitle: 'Once a day at most',
                value: prefs.flag('streakBreakAlert', false),
                onChanged: (v) => notifier.put('streakBreakAlert', v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your own prayer reminders are under More → Notifications & widgets.',
          textAlign: TextAlign.center,
          style: t.bodySmall,
        ),
      ],
    );
  }
}
