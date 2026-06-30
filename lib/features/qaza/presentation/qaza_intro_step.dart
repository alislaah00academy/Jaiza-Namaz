import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const _kInfoItems = [
  _InfoItem(
    icon: Icons.person_outline,
    title: 'Start from Bulugh (Puberty)',
    body: 'Begin counting from the day you became Islamically accountable.',
  ),
  _InfoItem(
    icon: Icons.edit_note_outlined,
    title: 'Make Your Best Estimate',
    body:
        "If you don't remember the exact date, enter your most reasonable estimate.",
  ),
  _InfoItem(
    icon: Icons.mosque_outlined,
    title: 'Count Only Missed Obligatory Prayers',
    body:
        'Include only the obligatory prayers you missed: Fajr, Zuhr, Asr, Maghrib, Isha, and Witr.',
  ),
  _InfoItem(
    icon: Icons.calendar_month_outlined,
    title: 'Calculate the Period',
    body: 'Estimate how many years, months, and days you missed each prayer.',
  ),
  _InfoItem(
    icon: Icons.description_outlined,
    title: 'Enter Each Prayer Separately',
    body:
        'Each prayer may have a different number of missed prayers, so calculate them individually.',
  ),
  _InfoItem(
    icon: Icons.notifications_outlined,
    title: 'Set Your Qaza Goal',
    body:
        "Choose how many Qaza prayers you want to complete daily or weekly. Jaiza will remind you according to your schedule.",
  ),
];

/// Step 1 of the Qaza wizard: explains how to estimate a missed-prayer
/// backlog before asking for numbers. Shown once, the first time a user
/// opens Qaza with no plan saved yet.
class QazaIntroStep extends StatelessWidget {
  const QazaIntroStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          QazaStepProgress(currentStep: 0),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'CALCULATE YOUR\n',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'QAZA PRAYERS',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.tertiary,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const JaizaFlourishDivider(),
          const SizedBox(height: 14),
          Text(
            'Estimate your missed obligatory prayers from the time you '
            'reached Bulugh (Puberty) until today.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _kInfoItems.length; i++)
            _NumberedInfoCard(index: i + 1, item: _kInfoItems[i]),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.tertiary,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: scheme.onTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Note',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This calculation is only an estimate. Islam '
                        'encourages sincere effort when the exact number is '
                        'unknown. Enter your best estimate and remain '
                        'consistent.',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('NEXT'),
            style: AppTheme.tonalButtonStyle(context).copyWith(
              backgroundColor: WidgetStatePropertyAll(scheme.tertiary),
              foregroundColor: WidgetStatePropertyAll(scheme.onTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedInfoCard extends StatelessWidget {
  const _NumberedInfoCard({required this.index, required this.item});

  final int index;
  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: JaizaSurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(item.icon, color: scheme.secondary, size: 22),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: scheme.tertiary,
                    child: Text(
                      '$index',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Step 1 of 2" progress indicator shared by intro + form steps.
class QazaStepProgress extends StatelessWidget {
  const QazaStepProgress({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['Calculate Qaza', 'Enter Qaza Details'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return JaizaSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${currentStep + 1} of 2',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.tertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                CircleAvatar(
                  radius: 5,
                  backgroundColor: i <= currentStep
                      ? scheme.tertiary
                      : scheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  _labels[i],
                  style: textTheme.labelSmall?.copyWith(
                    color: i <= currentStep
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: i == currentStep
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                if (i == 0) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 1, color: scheme.outlineVariant),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}
