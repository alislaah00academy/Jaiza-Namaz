import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../data/qaza_plan.dart';
import '../data/qaza_tracker.dart';
import 'qaza_widgets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/prayer_labels.dart';

enum _Mode { same, each }

/// "My estimate" — Qaza from before Jaiza, either one span for all five
/// prayers or a count per prayer. Saved to the existing `qazaPlan`.
class QazaEstimateScreen extends ConsumerStatefulWidget {
  const QazaEstimateScreen({super.key});

  @override
  ConsumerState<QazaEstimateScreen> createState() => _QazaEstimateScreenState();
}

class _QazaEstimateScreenState extends ConsumerState<QazaEstimateScreen> {
  _Mode _mode = _Mode.same;
  final _years = TextEditingController();
  final _months = TextEditingController();
  final _days = TextEditingController();
  final _each = {for (final p in kQazaPrayerNames) p: TextEditingController()};
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_years, _months, _days, ..._each.values]) {
      c.dispose();
    }
    super.dispose();
  }

  int _n(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  int get _sameDays => _n(_years) * 365 + _n(_months) * 30 + _n(_days);

  int _countFor(PrayerName p) =>
      _mode == _Mode.same ? _sameDays : _n(_each[p]!);

  int get _total => kQazaPrayerNames.fold(0, (s, p) => s + _countFor(p));

  void _seed(QazaPlanParsed plan) {
    if (_seeded) return;
    _seeded = true;
    if (!plan.setupComplete) return;
    final first = plan.backlogFor(kQazaPrayerNames.first);
    final allSame = kQazaPrayerNames.every((p) {
      final b = plan.backlogFor(p);
      return b.years == first.years &&
          b.months == first.months &&
          b.days == first.days;
    });
    if (allSame) {
      _mode = _Mode.same;
      _years.text = first.years == 0 ? '' : '${first.years}';
      _months.text = first.months == 0 ? '' : '${first.months}';
      _days.text = first.days == 0 ? '' : '${first.days}';
    } else {
      _mode = _Mode.each;
    }
    for (final p in kQazaPrayerNames) {
      final d = plan.backlogFor(p).totalDays;
      _each[p]!.text = d == 0 ? '' : '$d';
    }
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final backlogs = <PrayerName, QazaPrayerBacklog>{
      for (final p in kQazaPrayerNames)
        p: _mode == _Mode.same
            ? QazaPrayerBacklog(
                years: _n(_years),
                months: _n(_months),
                days: _n(_days),
              )
            : QazaPrayerBacklog(days: _n(_each[p]!)),
    };
    try {
      await ref
          .read(userRepositoryProvider)
          .updateQazaPlan(
            uid: uid,
            qazaPlan: QazaPlanParsed(
              setupComplete: true,
              backlogs: backlogs,
            ).toFirestoreMap(),
          );
      await ref.read(qazaIntroDoneProvider.notifier).set(true);
      if (mounted) context.pushReplacement('/app/qaza/plan');
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.errorSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = ref.watch(appUserStreamProvider).value;
    _seed(user?.qazaPlanParsed ?? QazaPlanParsed.defaults());
    final since = ref.watch(qazaTrackingSinceProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzNoteCard(
          body: _mode == _Mode.same
              ? Text.rich(
                  TextSpan(
                    text: context.l10n.qazaEstimateOnlyMissedPrefix,
                    children: [
                      TextSpan(
                        text: context.l10n.qazaEstimateBeforeInstalled,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: context.l10n.qazaEstimateOnlyMissedSuffix(
                          DateFormat(
                            'd MMMM y',
                            context.l10n.localeName,
                          ).format(since),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(context.l10n.qazaEstimateEachIntro),
        ),
        const SizedBox(height: 16),
        JzSectionLabel(context.l10n.qazaEstimateHowEnter),
        JzSegmented<_Mode>(
          options: {
            _Mode.same: context.l10n.qazaEstimateSameForAll,
            _Mode.each: context.l10n.qazaEstimateEachPrayer,
          },
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: 16),
        if (_mode == _Mode.same) ..._sameCards(t) else _eachCard(t),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.qazaTotalEstimate,
                  style: t.titleMedium,
                ),
              ),
              Text(jzCount(_total), style: t.headlineSmall),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const JzImportantNote(),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.qazaSaveEstimate),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _bigField(TextEditingController c, String label) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          TextField(
            controller: c,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: t.titleLarge?.copyWith(
              fontSize: 21,
              fontFamily: t.bodyLarge?.fontFamily,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: '0',
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: t.labelSmall),
        ],
      ),
    );
  }

  List<Widget> _sameCards(TextTheme t) => [
    JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.qazaHowLongNotPraying, style: t.titleMedium),
          const SizedBox(height: 2),
          Text(context.l10n.qazaBestGuessEnough, style: t.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              _bigField(_years, context.l10n.unitYears),
              const SizedBox(width: 10),
              _bigField(_months, context.l10n.unitMonths),
              const SizedBox(width: 10),
              _bigField(_days, context.l10n.unitDays),
            ],
          ),
          const JzDivider(top: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.qazaThatIsAboutDays(jzCount(_sameDays)),
                  style: t.bodyMedium,
                ),
              ),
              JzChip(context.l10n.qazaEach(jzCount(_sameDays)), gold: true),
            ],
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    JzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(context.l10n.qazaEveryPrayerSame, style: t.titleMedium),
          ),
          for (var i = 0; i < kQazaPrayerNames.length; i++)
            JzListRow(
              leading: JzAvatar(
                icon: prayerIcon(kQazaPrayerNames[i]),
                size: 36,
                iconSize: 18,
              ),
              title: kQazaPrayerNames[i].label(context.l10n),
              showDivider: i < kQazaPrayerNames.length - 1,
              trailing: Text(jzCount(_sameDays), style: t.titleSmall),
            ),
        ],
      ),
    ),
  ];

  Widget _eachCard(TextTheme t) => JzCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.qazaHowManyEach, style: t.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < kQazaPrayerNames.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                JzAvatar(
                  icon: prayerIcon(kQazaPrayerNames[i]),
                  size: 36,
                  iconSize: 18,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    kQazaPrayerNames[i].label(context.l10n),
                    style: t.bodyLarge,
                  ),
                ),
                SizedBox(
                  width: 118,
                  child: TextField(
                    controller: _each[kQazaPrayerNames[i]],
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(minHeight: 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i < kQazaPrayerNames.length - 1)
            const JzDivider(top: 0, bottom: 0),
        ],
      ],
    ),
  );
}
