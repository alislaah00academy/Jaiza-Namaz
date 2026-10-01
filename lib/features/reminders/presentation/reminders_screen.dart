import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/formatters.dart';
import '../../../core/l10n/prayer_labels.dart';

/// Read-only feed of today's prayer reminders in order, with their
/// start/end on-off state. Actual toggles live in Profile → Widgets &
/// Notifications — this screen is just "what's coming up today."
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerSettingsProvider);
    final cardAsync = ref.watch(currentPrayerCardProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                settings.notificationsEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  settings.notificationsEnabled
                      ? context.l10n.remindersOn
                      : context.l10n.remindersOff,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/app/widget-settings'),
                child: Text(context.l10n.manage),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.todaysPrayers,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        cardAsync.when(
          data: (data) => Column(
            children: [
              for (final (i, window) in data.today.fardWindows.indexed)
                _ReminderRow(
                  label: window.prayer.label(context.l10n),
                  time: window.start,
                  startOn: settings.startNotificationFor(
                    PrayerNameX.fromFirestore(window.key) ?? PrayerName.fajr,
                  ),
                  endOn: settings.notificationFor(
                    PrayerNameX.fromFirestore(window.key) ?? PrayerName.fajr,
                  ),
                  isActive: data.status.activePrayerKey == window.key,
                ).jaizaEnter(index: i),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text(
            context.l10n.prayerTimesUnavailable,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.label,
    required this.time,
    required this.startOn,
    required this.endOn,
    required this.isActive,
  });

  final String label;
  final DateTime time;
  final bool startOn;
  final bool endOn;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isActive ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(Icons.notifications_outlined, color: scheme.secondary),
        ),
        title: Text(label, style: textTheme.titleSmall),
        subtitle: Text(formatTimePadded(time, context.l10n)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleDot(label: context.l10n.reminderStart, on: startOn),
            const SizedBox(width: 8),
            _ToggleDot(label: context.l10n.reminderEnd, on: endOn),
          ],
        ),
      ),
    );
  }
}

class _ToggleDot extends StatelessWidget {
  const _ToggleDot({required this.label, required this.on});

  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          on ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: on ? scheme.primary : scheme.outline,
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
