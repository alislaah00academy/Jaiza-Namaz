import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/jaiza_motion.dart';
import '../../../core/constants/prayer_catalog.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/jaiza_dates.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/prayer_log.dart';
import '../../../providers/providers.dart';
import '../../../services/prayer_times_service.dart';
import '../../../data/models/child_profile.dart';
import '../../mosques/data/mosque_data.dart';
import '../../parent/data/family_data.dart';
import '../../parent/presentation/family_widgets.dart';
import '../../qaza/data/qaza_tracker.dart';
import 'prayer_marking.dart';

String _hm(DateTime t) => DateFormat('h:mm a').format(t.toLocal());
String _hhm(DateTime t) => DateFormat('hh:mm a').format(t.toLocal());

/// Today — the landing screen. The primary mosque's Jama'at time is the
/// hero, and the five Fard prayers are ticked straight from the list.
class HomeHubScreen extends ConsumerStatefulWidget {
  const HomeHubScreen({super.key});

  @override
  ConsumerState<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends ConsumerState<HomeHubScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keep "current prayer" and the Jama'at countdown fresh.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(currentPrayerCardProvider);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(currentPrayerCardProvider).valueOrNull;
    final user = ref.watch(appUserStreamProvider).valueOrNull;
    final fard = ref.watch(todayFardMapProvider).valueOrNull ?? const {};
    final nawafilOn = user?.nawafilEnabled ?? false;
    final nawafilLogs = ref.watch(todayNawafilProvider).valueOrNull ?? const [];
    final nawafilDone = kNawafilDefs
        .where(
          (d) => nawafilLogs.any(
            (l) => l.prayerName == d.name && l.status == PrayerStatus.completed,
          ),
        )
        .length;
    final qaza = ref.watch(qazaOverviewProvider);
    final isParent = ref.watch(isParentProvider);
    final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
    final child = isParent
        ? childById(children, ref.watch(selectedChildIdProvider))
        : null;

    if (child != null) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _HeaderCard(data: card),
          const _AddChildrenStrip(),
          const PersonChipRow(),
          _ChildView(child: child, data: card),
          const SizedBox(height: 4),
          const JaizaMosqueSkyline(),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _HeaderCard(data: card).jaizaEnter(),
        _StreakStrip(
          done: kFardPrayerDefs
              .where((d) => fard[d.name]?.status == PrayerStatus.completed)
              .length,
        ).jaizaEnter(index: 1),
        if (isParent) ...[const _AddChildrenStrip(), const PersonChipRow()],
        _PrayerListCard(data: card, logs: fard).jaizaEnter(index: 2),
        JzStripCard(
          icon: Icons.front_hand_outlined,
          title: 'Nawafil',
          subtitle: nawafilOn
              ? '$nawafilDone of ${kNawafilDefs.length} done today'
              : 'Tracking off — tap to turn on',
          onTap: () => context.push('/app/nawafil'),
        ).jaizaEnter(index: 3),
        JzStripCard(
          icon: Icons.history_edu_outlined,
          title: 'Qaza',
          subtitle: qaza.remaining == 0
              ? 'Nothing to make up'
              : '${jzCount(qaza.remaining)} prayers to make up',
          onTap: () => context.push('/app/qaza'),
        ).jaizaEnter(index: 4),
        if (isParent && children.isNotEmpty) _FamilyCard(children: children),
        const SizedBox(height: 4),
        const JaizaMosqueSkyline(),
      ],
    );
  }
}

typedef _CardData = ({DailyPrayerSchedule today, PrayerWindowStatus status});

class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({required this.data});

  final _CardData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final d = data;
    final activeKey = d?.status.activePrayerKey;
    final window = d == null || activeKey == null
        ? null
        : d.today.fardWindows.firstWhere((w) => w.key == activeKey);
    final label = window?.label ?? d?.status.nextLabel ?? '—';
    final key = window?.key ?? d?.status.nextKey;
    final start = window?.start ?? d?.status.nextTime;
    final end =
        window?.end ??
        (key == null || d == null
            ? null
            : d.today.fardWindows
                  .firstWhere(
                    (w) => w.key == key,
                    orElse: () => d.today.fardWindows.first,
                  )
                  .end);
    final prayer = key == null ? null : PrayerNameX.fromFirestore(key);
    final mosque = ref.watch(primaryMosqueProvider);

    return JzCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/branding/jaiza_emblem.png',
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatHijriDate(now),
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(formatGregorianFull(now), style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text(
              AppStrings.academyCredit,
              style: t.labelSmall?.copyWith(letterSpacing: 0.3),
            ),
          ),
          const JzDivider(top: 11, bottom: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                window != null
                    ? PulsingDot(color: jzGreen(context), size: 9)
                    : Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.outline,
                        ),
                      ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  window != null ? 'Current prayer' : 'Next prayer',
                  style: t.bodySmall?.copyWith(
                    color: window != null
                        ? jzGreen(context)
                        : c.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (mosque != null && prayer != null)
            _JamaatBox(mosque: mosque, prayer: prayer, nextDay: _isTomorrow(d))
          else
            JzDashedAction(
              gold: false,
              radius: 16,
              icon: Icons.mosque_outlined,
              title: 'Set your primary mosque',
              subtitle: "To see Jama'at times for every prayer",
              trailing: TextButton(
                onPressed: () => context.go('/app/mosques'),
                child: const Text('Find'),
              ),
              onTap: () => context.go('/app/mosques'),
            ),
          const JzDivider(top: 12, bottom: 10),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _TimeCell(
                    icon: Icons.wb_twilight_outlined,
                    label: 'Starts',
                    time: start == null ? '—' : _hhm(start),
                  ),
                ),
                VerticalDivider(width: 1, color: c.outlineVariant),
                Expanded(
                  child: _TimeCell(
                    icon: Icons.nights_stay_outlined,
                    label: 'Ends',
                    time: end == null ? '—' : _hhm(end),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// After Isha the "next" prayer is tomorrow's Fajr.
  bool _isTomorrow(_CardData? d) {
    if (d == null || d.status.activePrayerKey != null) return false;
    return d.status.nextTime.day != DateTime.now().day;
  }
}

class _JamaatBox extends StatelessWidget {
  const _JamaatBox({
    required this.mosque,
    required this.prayer,
    required this.nextDay,
  });

  final Mosque mosque;
  final PrayerName prayer;
  final bool nextDay;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final day = nextDay ? now.add(const Duration(days: 1)) : now;
    final at = mosque.jamaatOn(day, prayer);
    String when = '';
    if (at != null) {
      final diff = at.difference(now);
      if (diff.inMinutes > 0) {
        when = ' · starts in ${PrayerTimesService.compactDuration(diff)}';
      } else if (diff.inMinutes > -30) {
        when = ' · started ${-diff.inMinutes} min ago';
      }
    }
    return Material(
      color: c.tertiaryContainer.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.tertiary.withValues(alpha: 0.32)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/app/mosques/${mosque.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const JzAvatar(
                    icon: Icons.mosque_outlined,
                    size: 34,
                    iconSize: 18,
                    tone: JzAvatarTone.gold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Jama'at",
                      style: t.titleSmall?.copyWith(letterSpacing: 0.3),
                    ),
                  ),
                  Text(
                    mosque.longTime(prayer),
                    style: t.titleLarge?.copyWith(
                      fontSize: 21,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 46, top: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${mosque.name}$when',
                        style: t.bodySmall?.copyWith(color: c.onSurface),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: c.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.icon,
    required this.label,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.primary),
            const SizedBox(width: 7),
            Text(label, style: t.labelSmall),
            const SizedBox(width: 7),
            Text(
              time,
              style: t.titleSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStrip extends ConsumerWidget {
  const _StreakStrip({required this.done});

  final int done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final streak = ref.watch(streakStreamProvider).valueOrNull;
    final current = streak?.currentStreak ?? 0;
    final best = streak?.longestStreak ?? 0;
    final total = kFardPrayerDefs.length;
    return JzStripCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      icon: Icons.local_fire_department_outlined,
      iconColor: c.tertiary,
      title: '$current-day streak',
      subtitle: best > 0
          ? 'Best so far — $best ${best == 1 ? 'day' : 'days'}'
          : 'Pray all five to start one',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$done of $total today',
            style: t.labelSmall?.copyWith(color: c.onSurface),
          ),
          const SizedBox(height: 5),
          JzBar(value: done / total, width: 72),
        ],
      ),
    );
  }
}

class _PrayerListCard extends ConsumerWidget {
  const _PrayerListCard({
    required this.data,
    required this.logs,
    this.personId,
  });

  final _CardData? data;
  final Map<PrayerName, PrayerLog> logs;

  /// A child's id when a parent is marking for them.
  final String? personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosque = ref.watch(primaryMosqueProvider);
    final now = DateTime.now();
    final d = data;
    return JzCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          for (var i = 0; i < kFardPrayerDefs.length; i++)
            Builder(
              builder: (context) {
                final def = kFardPrayerDefs[i];
                final log = logs[def.name];
                final done = log?.status == PrayerStatus.completed;
                final window = d?.today.fardWindows.firstWhere(
                  (w) => w.key == def.name.name,
                );
                final isCurrent = d?.status.activePrayerKey == def.name.name;
                final ended = window != null && window.end.isBefore(now);
                final state = done
                    ? JzRowState.normal
                    : isCurrent
                    ? JzRowState.current
                    : ended
                    ? JzRowState.missed
                    : JzRowState.normal;
                final range = window == null
                    ? '${def.startHint} — ${def.endHint}'
                    : '${_hm(window.start)} – ${_hm(window.end)}';
                Widget? sub;
                String? subText = range;
                if (state == JzRowState.current) subText = 'Now · $range';
                if (state == JzRowState.missed) {
                  subText = null;
                  sub = log?.status == PrayerStatus.missed
                      ? Text(
                          personId == null
                              ? 'Missed · in your Qaza list'
                              : 'Missed · in the Qaza list',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      : MissedAddToQaza(
                          onAdd: () => addMissedToQaza(
                            context,
                            ref,
                            name: def.name,
                            label: def.label,
                            personId: personId,
                          ),
                        );
                }
                return JzPrayerRow(
                  name: def.label,
                  checked: done,
                  state: state,
                  sub: subText,
                  subWidget: sub,
                  showDivider: i < kFardPrayerDefs.length - 1,
                  trailing: mosque == null
                      ? null
                      : JzJamaatChip(mosque.shortTime(def.name)),
                  onToggle: () => togglePrayer(
                    context,
                    ref,
                    name: def.name,
                    label: def.label,
                    type: PrayerType.fard,
                    currentlyDone: done,
                    personId: personId,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// "Add children" strip — lists the children, "+" opens the add sheet.
class _AddChildrenStrip extends ConsumerWidget {
  const _AddChildrenStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
    return JzStripCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      icon: Icons.family_restroom_outlined,
      title: 'Add children',
      subtitle: children.isEmpty
          ? 'Mark their prayers from this same screen'
          : children.map((k) => k.name).join(' · '),
      onTap: () => showAddChildSheet(context),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.primary),
        child: Icon(Icons.add_rounded, size: 20, color: c.onPrimary),
      ),
    );
  }
}

/// Today for one child: summary, streak, their Fard list, Nawafil and Qaza.
class _ChildView extends ConsumerWidget {
  const _ChildView({required this.child, required this.data});

  final ChildProfile child;
  final _CardData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final logs =
        ref.watch(personFardLogsProvider(child.id)).valueOrNull ?? const [];
    final nawafil =
        ref.watch(personNawafilLogsProvider(child.id)).valueOrNull ?? const [];
    final extra = ref.watch(childExtrasProvider)[child.id];
    final today = DateTime.now();
    final todayMap = logsOnDay(logs, today);
    final done = fardDoneOn(logs, today);
    final week = fardDoneThisWeek(logs);
    final (streak, best) = fardStreak(logs);
    final nawafilMap = logsOnDay(nawafil, today);
    final nawafilDone = kNawafilDefs
        .where((d) => nawafilMap[d.name]?.status == PrayerStatus.completed)
        .length;
    final qaza = ref.watch(childQazaOverviewProvider(child.id));
    final total = kFardPrayerDefs.length;

    return Column(
      children: [
        JzCard(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              LetterAvatar(child.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extra?.age == null
                          ? child.name
                          : '${child.name} · ${extra!.age} years',
                      style: t.titleSmall,
                    ),
                    Text(
                      'Today $done of $total · this week $week of ${total * 7}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/app/history'),
                child: const Text('History'),
              ),
            ],
          ),
        ),
        JzStripCard(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          icon: Icons.local_fire_department_outlined,
          iconColor: c.tertiary,
          title: '${child.name} — $streak-day streak',
          subtitle: best > 0
              ? 'Best so far — $best ${best == 1 ? 'day' : 'days'}'
              : 'All five in a day starts a streak',
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$done of $total today',
                style: t.labelSmall?.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: 5),
              JzBar(value: done / total, width: 72),
            ],
          ),
        ),
        _PrayerListCard(data: data, logs: todayMap, personId: child.id),
        JzStripCard(
          icon: Icons.front_hand_outlined,
          title: 'Nawafil',
          subtitle: '$nawafilDone of ${kNawafilDefs.length} done today',
          onTap: () => context.push('/app/nawafil'),
        ),
        JzStripCard(
          icon: Icons.history_edu_outlined,
          title: 'Qaza',
          subtitle: qaza.remaining == 0
              ? 'Nothing to make up'
              : '${jzCount(qaza.remaining)} to make up · since '
                    '${DateFormat('d MMMM').format(qaza.since)}',
          onTap: () => context.push('/app/family/qaza/${child.id}'),
        ),
      ],
    );
  }
}

/// Family card on the parent's own Today: who still has prayers outstanding.
class _FamilyCard extends ConsumerWidget {
  const _FamilyCard({required this.children});

  final List<ChildProfile> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final total = kFardPrayerDefs.length;
    return JzCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Family', style: t.titleMedium)),
              TextButton(
                onPressed: () => context.push('/app/family'),
                child: const Text('See all'),
              ),
            ],
          ),
          for (final k in children)
            Builder(
              builder: (context) {
                final logs =
                    ref.watch(personFardLogsProvider(k.id)).valueOrNull ??
                    const [];
                final done = fardDoneOn(logs, DateTime.now());
                final (streak, _) = fardStreak(logs);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      ref.read(selectedChildIdProvider.notifier).state = k.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        LetterAvatar(k.name),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(k.name, style: t.titleSmall),
                                  ),
                                  Icon(
                                    Icons.local_fire_department_outlined,
                                    size: 14,
                                    color: c.tertiary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text('$streak', style: t.labelSmall),
                                ],
                              ),
                              const SizedBox(height: 6),
                              JzBar(value: done / total),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$done/$total',
                          style: t.titleSmall?.copyWith(
                            color: done == total
                                ? c.primary
                                : c.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: c.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
