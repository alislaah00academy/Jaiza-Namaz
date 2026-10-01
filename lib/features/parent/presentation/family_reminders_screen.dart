import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/family_data.dart';
import 'family_widgets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/formatters.dart';

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
    final children = ref.watch(childrenStreamProvider).value ?? const [];
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
                  Expanded(
                    child: Text(
                      context.l10n.titleFamilyReminders,
                      style: t.titleMedium,
                    ),
                  ),
                  JzChip(context.l10n.newBadge, gold: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(context.l10n.familyRemindersIntro, style: t.bodySmall),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                        Text(context.l10n.appName, style: t.labelSmall),
                        const Spacer(),
                        Text(context.l10n.notificationNow, style: t.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.childHasntMarked(
                        context.l10n.previewChildName,
                        context.l10n.prayerAsr,
                      ),
                      style: t.titleSmall,
                    ),
                    Text(
                      context.l10n.minutesLeftInWindow(30),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.whatAlertLooksLike,
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
              Text(context.l10n.whenYouAreAlerted, style: t.titleMedium),
              const SizedBox(height: 10),
              JzSwitchRow(
                title: context.l10n.beforeWindowCloses,
                subtitle: context.l10n.oneNudgePerPrayer,
                value: prefs.flag('beforeClose'),
                onChanged: (v) => notifier.put('beforeClose', v),
              ),
              const JzDivider(),
              Row(
                children: [
                  Expanded(
                    child: Text(context.l10n.howEarly, style: t.bodyLarge),
                  ),
                  PopupMenuButton<int>(
                    initialValue: prefs.number('earlyMinutes', 30),
                    onSelected: (v) => notifier.put('earlyMinutes', v),
                    itemBuilder: (_) => [
                      for (final m in const [10, 15, 20, 30, 45])
                        PopupMenuItem(
                          value: m,
                          child: Text(context.l10n.minCount(m)),
                        ),
                    ],
                    child: JzChip(
                      context.l10n.minCount(prefs.number('earlyMinutes', 30)),
                      gold: true,
                    ),
                  ),
                ],
              ),
              const JzDivider(),
              Text(context.l10n.whichPrayers, style: t.bodyLarge),
              const SizedBox(height: 2),
              Text(context.l10n.whichPrayersBody, style: t.bodySmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final def in kFardPrayerDefs)
                    JzChip(
                      def.label(context.l10n),
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
                title: context.l10n.eveningSummary,
                subtitle: context.l10n.eveningSummarySubtitle,
                value: prefs.flag('eveningSummary'),
                onChanged: (v) => notifier.put('eveningSummary', v),
              ),
              if (prefs.flag('eveningSummary')) ...[
                const JzDivider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.summaryTime, style: t.bodyLarge),
                    ),
                    JzChip(
                      formatTime(
                        DateTime(
                          2000,
                          1,
                          1,
                          prefs.number('summaryHour', 21),
                          30,
                        ),
                        context.l10n,
                      ),
                      gold: true,
                    ),
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
              Text(context.l10n.keepingItQuiet, style: t.titleMedium),
              const SizedBox(height: 10),
              JzSwitchRow(
                title: context.l10n.quietHours,
                subtitle: context.l10n.quietHoursSubtitle,
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
                        Text(context.l10n.dailyLimit, style: t.bodyLarge),
                        Text(
                          context.l10n.dailyLimitSubtitle,
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
                        PopupMenuItem(
                          value: m,
                          child: Text(context.l10n.perDay(m)),
                        ),
                    ],
                    child: JzChip(
                      context.l10n.perDay(prefs.number('dailyLimit', 4)),
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
              Text(context.l10n.titleChildren, style: t.titleMedium),
              const SizedBox(height: 2),
              Text(context.l10n.childrenMuteBody, style: t.bodySmall),
              const SizedBox(height: 10),
              if (children.isEmpty)
                Text(context.l10n.addChildToSetUp, style: t.bodyMedium)
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
                        subtitle: extra?.age == null
                            ? null
                            : context.l10n.ageYears(extra!.age!),
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
                title: context.l10n.streakBreakAlert,
                subtitle: context.l10n.onceADayAtMost,
                value: prefs.flag('streakBreakAlert', false),
                onChanged: (v) => notifier.put('streakBreakAlert', v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.ownRemindersHint,
          textAlign: TextAlign.center,
          style: t.bodySmall,
        ),
      ],
    );
  }
}
