import 'package:flutter/material.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/prayer_log.dart';
import '../data/qaza_plan.dart';
import 'qaza_intro_step.dart';

IconData qazaIconFor(PrayerName name) => switch (name) {
  PrayerName.fajr => Icons.wb_twilight_outlined,
  PrayerName.zuhr => Icons.wb_sunny_outlined,
  PrayerName.asr => Icons.brightness_5_outlined,
  PrayerName.maghrib => Icons.wb_twilight,
  PrayerName.isha => Icons.nightlight_round,
  PrayerName.witr => Icons.bedtime_outlined,
  _ => Icons.access_time,
};

class _FrequencyOption {
  const _FrequencyOption(this.frequency, this.icon);
  final QazaFrequency frequency;
  final IconData icon;
}

const _kFrequencyOptions = [
  _FrequencyOption(QazaFrequency.daily, Icons.event_repeat_outlined),
  _FrequencyOption(QazaFrequency.weekly, Icons.view_week_outlined),
  _FrequencyOption(QazaFrequency.monthly, Icons.calendar_month_outlined),
  _FrequencyOption(QazaFrequency.yearly, Icons.calendar_today_outlined),
  _FrequencyOption(QazaFrequency.custom, Icons.schedule_outlined),
];

/// Step 2 of the Qaza wizard: per-prayer backlog entry + reminder
/// frequency. The frequency picker only saves a preference for now — no
/// recurring notification is actually scheduled from it yet.
class QazaFormStep extends StatefulWidget {
  const QazaFormStep({
    super.key,
    required this.initial,
    required this.onBack,
    required this.onSave,
    required this.showStepProgress,
  });

  final QazaPlanParsed initial;
  final VoidCallback onBack;
  final ValueChanged<QazaPlanParsed> onSave;

  /// False when reached via "Edit backlog" from the dashboard — skips the
  /// "Step 2 of 2" header since there's no step 1 in that flow.
  final bool showStepProgress;

  @override
  State<QazaFormStep> createState() => _QazaFormStepState();
}

class _RowControllers {
  _RowControllers(QazaPrayerBacklog backlog)
    : days = TextEditingController(text: '${backlog.days}'),
      months = TextEditingController(text: '${backlog.months}'),
      years = TextEditingController(text: '${backlog.years}'),
      frequency = backlog.frequency;

  final TextEditingController days;
  final TextEditingController months;
  final TextEditingController years;
  QazaFrequency? frequency;

  int get totalDays {
    final y = int.tryParse(years.text) ?? 0;
    final m = int.tryParse(months.text) ?? 0;
    final d = int.tryParse(days.text) ?? 0;
    return y * 365 + m * 30 + d;
  }

  void dispose() {
    days.dispose();
    months.dispose();
    years.dispose();
  }
}

class _QazaFormStepState extends State<QazaFormStep> {
  late final Map<PrayerName, _RowControllers> _rows = {
    for (final n in kQazaPrayerNames)
      n: _RowControllers(widget.initial.backlogFor(n)),
  };

  @override
  void dispose() {
    for (final r in _rows.values) {
      r.dispose();
    }
    super.dispose();
  }

  void _save() {
    final backlogs = <PrayerName, QazaPrayerBacklog>{};
    for (final entry in _rows.entries) {
      final r = entry.value;
      backlogs[entry.key] = QazaPrayerBacklog(
        days: int.tryParse(r.days.text) ?? 0,
        months: int.tryParse(r.months.text) ?? 0,
        years: int.tryParse(r.years.text) ?? 0,
        frequency: r.frequency,
      );
    }
    widget.onSave(QazaPlanParsed(setupComplete: true, backlogs: backlogs));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
              if (widget.showStepProgress)
                const Expanded(child: QazaStepProgress(currentStep: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'QAZA PRAYERS FORM',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const JaizaFlourishDivider(),
          const SizedBox(height: 10),
          Text(
            "Track your missed prayers and choose how you'll make each one up.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(14),
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
                  child: Text(
                    'Fill in the missed (Qaza) prayers you want to make up. '
                    'We will help you stay consistent by sending timely '
                    'reminders.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final def in kFardPrayerDefs)
            _PrayerBacklogCard(
              label: def.label,
              icon: qazaIconFor(def.name),
              controllers: _rows[def.name]!,
              onFrequencyChanged: (f) =>
                  setState(() => _rows[def.name]!.frequency = f),
              onChanged: () => setState(() {}),
            ),
          const SizedBox(height: 8),
          _FrequencyLegend(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('SAVE & SET REMINDERS'),
            style: AppTheme.tonalButtonStyle(context).copyWith(
              backgroundColor: WidgetStatePropertyAll(scheme.tertiary),
              foregroundColor: WidgetStatePropertyAll(scheme.onTertiary),
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We will send you reminders according to the frequency you '
            'select. (Reminder scheduling is coming soon — for now this '
            'just saves your preference.)',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerBacklogCard extends StatelessWidget {
  const _PrayerBacklogCard({
    required this.label,
    required this.icon,
    required this.controllers,
    required this.onFrequencyChanged,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final _RowControllers controllers;
  final ValueChanged<QazaFrequency?> onFrequencyChanged;
  final VoidCallback onChanged;

  Widget _numberField(
    BuildContext context,
    TextEditingController c,
    String hint,
  ) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        hintText: hint,
      ),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _numberFieldsRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _numberField(context, controllers.days, '0')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, controllers.months, '0')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(context, controllers.years, '0')),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                'Days',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Months',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Years',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Total Qaza $label',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTokens.radiusChip),
              ),
              child: Text(
                '${controllers.totalDays}',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _frequencyPicker(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you want to make up this Qaza?',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<QazaFrequency>(
          initialValue: controllers.frequency,
          isExpanded: true,
          decoration: const InputDecoration(isDense: true),
          hint: const Text('Select Frequency'),
          items: [
            for (final opt in _kFrequencyOptions)
              DropdownMenuItem(
                value: opt.frequency,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(opt.icon, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(opt.frequency.label),
                  ],
                ),
              ),
          ],
          onChanged: onFrequencyChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final header = Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: scheme.secondaryContainer,
          child: Icon(icon, color: scheme.secondary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Qaza $label Namaz',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: JaizaSurfaceCard(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Mirrors the reference design's 3-column row on wide screens;
            // stacks vertically on phones so nothing gets squeezed/overflows.
            if (constraints.maxWidth >= 640) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 200, child: header),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _numberFieldsRow(context)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _frequencyPicker(context)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 12),
                _numberFieldsRow(context),
                const SizedBox(height: 14),
                _frequencyPicker(context),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FrequencyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return JaizaSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'FREQUENCY OPTIONS',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final opt in _kFrequencyOptions)
                SizedBox(
                  width: 96,
                  child: Column(
                    children: [
                      Icon(opt.icon, color: scheme.primary, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        opt.frequency.label,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        opt.frequency.hint,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
