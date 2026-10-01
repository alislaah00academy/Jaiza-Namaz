import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prayer_catalog.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/home_widget_bridge.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../features/settings/data/prayer_settings.dart';
import '../../../providers/providers.dart';
import '../../../services/location_service.dart';
import '../../../services/notifications_service.dart';
import '../../../data/models/user_role.dart';
import '../../mosques/data/mosque_data.dart';
import '../../organization/data/org_extras.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/errors/firebase_auth_messages.dart';

/// Notifications & widgets: per-prayer reminders, Jama'at alerts, home
/// widgets, location, and prayer-time calculation.
class WidgetsNotificationsScreen extends ConsumerStatefulWidget {
  const WidgetsNotificationsScreen({super.key});

  @override
  ConsumerState<WidgetsNotificationsScreen> createState() =>
      _WidgetsNotificationsScreenState();
}

class _WidgetsNotificationsScreenState
    extends ConsumerState<WidgetsNotificationsScreen> {
  final _lat = TextEditingController();
  final _lon = TextEditingController();
  final _label = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _lat.dispose();
    _lon.dispose();
    _label.dispose();
    super.dispose();
  }

  Future<void> _apply(PrayerSettingsParsed next) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updatePrayerSettings(
            uid: uid,
            prayerSettings: next.toFirestoreMap(),
          );
      await HomeWidgetBridge.syncAllWidgets(ref);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, mapGenericError(e, context.l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveManualFromFields(PrayerSettingsParsed base) async {
    final lat = double.tryParse(_lat.text.trim());
    final lon = double.tryParse(_lon.text.trim());
    if (lat == null || lon == null) {
      AppSnackBar.error(context, context.l10n.enterValidLatLon);
      return;
    }
    final lab = _label.text.trim();
    await _apply(
      base.copyWith(
        manualLat: lat,
        manualLon: lon,
        manualLabel: lab.isEmpty ? base.manualLabel : lab,
      ),
    );
  }

  /// Turning any prayer on also turns reminders on (asking for permission
  /// the first time).
  Future<void> _setPrayer(PrayerSettingsParsed s, String key, bool on) async {
    final start = Map<String, bool>.from(s.startPrayerNotifications);
    final end = Map<String, bool>.from(s.perPrayerNotifications);
    var enabled = s.notificationsEnabled;
    if (on && !enabled) {
      final ok = await NotificationsService.instance
          .requestNotificationPermission();
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.error(context, context.l10n.notificationsBlocked);
        return;
      }
      enabled = true;
    }
    start[key] = on;
    end[key] = on;
    await _apply(
      s.copyWith(
        notificationsEnabled: enabled,
        startPrayerNotifications: start,
        perPrayerNotifications: end,
      ),
    );
  }

  Future<void> _detect(PrayerSettingsParsed settings) async {
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    if (pos == null) {
      AppSnackBar.error(context, context.l10n.couldNotGetLocation);
      return;
    }
    await _apply(
      settings.copyWith(
        manualLat: pos.lat,
        manualLon: pos.lon,
        manualLabel: pos.label ?? settings.manualLabel,
      ),
    );
    if (!mounted) return;
    setState(() {
      _lat.text = pos.lat.toString();
      _lon.text = pos.lon.toString();
      if (pos.label != null) _label.text = pos.label!;
    });
    AppSnackBar.success(context, context.l10n.locationDetected);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final settings = ref.watch(prayerSettingsProvider);
    if (uid == null) {
      return Center(child: Text(context.l10n.signInRequired));
    }

    if (!_seeded) {
      _lat.text = settings.manualLat.toString();
      _lon.text = settings.manualLon.toString();
      _label.text = settings.manualLabel;
      _seeded = true;
    }

    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final isTeacher =
        ref.watch(appUserStreamProvider).value?.orgMemberRole ==
        OrgMemberRole.teacher;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_saving) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        if (isTeacher) ...[
          const _ClassRemindersCard(),
          const SizedBox(height: 14),
        ],
        _prayerReminders(settings, t),
        const SizedBox(height: 14),
        const _JamaatAlertsCard(),
        const SizedBox(height: 14),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.homeWidgets, style: t.titleMedium),
              const SizedBox(height: 4),
              Text(context.l10n.homeWidgetsBody, style: t.bodySmall),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  await HomeWidgetBridge.syncAllWidgets(ref);
                  if (context.mounted) {
                    AppSnackBar.success(context, context.l10n.widgetsRefreshed);
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.refreshWidgetsNow),
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
              Text(context.l10n.locationTitle, style: t.titleMedium),
              const SizedBox(height: 8),
              JzSwitchRow(
                title: context.l10n.useMyCurrentLocation,
                subtitle: settings.manualLabel,
                value: settings.useGps,
                onChanged: (v) => _apply(settings.copyWith(useGps: v)),
              ),
              if (!settings.useGps) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _lat,
                  decoration: InputDecoration(labelText: context.l10n.latitude),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lon,
                  decoration: InputDecoration(
                    labelText: context.l10n.longitude,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _label,
                  decoration: InputDecoration(
                    labelText: context.l10n.placeLabel,
                  ),
                  onSubmitted: (_) => _saveManualFromFields(settings),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _saveManualFromFields(settings),
                  child: Text(context.l10n.saveManualLocation),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: () => _detect(settings),
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: Text(context.l10n.detectNow),
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
              Text(context.l10n.prayerTimeCalculation, style: t.titleMedium),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue:
                    PrayerSettingsParsed.calcMethodOptions.contains(
                      settings.calcMethod,
                    )
                    ? settings.calcMethod
                    : PrayerSettingsParsed.calcMethodOptions.first,
                decoration: InputDecoration(
                  labelText: context.l10n.calcMethodLabel,
                ),
                items: [
                  for (final k in PrayerSettingsParsed.calcMethodOptions)
                    DropdownMenuItem(
                      value: k,
                      child: Text(
                        PrayerSettingsParsed.calcMethodLabel(k, context.l10n),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) _apply(settings.copyWith(calcMethod: v));
                },
              ),
              const SizedBox(height: 14),
              Text(context.l10n.madhabLabel, style: t.titleSmall),
              const SizedBox(height: 8),
              JzSegmented<String>(
                options: {
                  'hanafi': context.l10n.madhabHanafi,
                  'shafi': context.l10n.madhabShafii,
                },
                selected: settings.madhab,
                onChanged: (m) => _apply(settings.copyWith(madhab: m)),
              ),
            ],
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              await NotificationsService.instance.scheduleTestIn(
                const Duration(seconds: 30),
              );
              if (context.mounted) {
                AppSnackBar.success(context, context.l10n.testNotificationIn30);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: c.onSurfaceVariant,
            ),
            child: Text(context.l10n.debugTestNotification),
          ),
        ],
      ],
    );
  }

  Widget _prayerReminders(PrayerSettingsParsed s, TextTheme t) {
    final start = s.startPrayerNotifications;
    final end = s.perPrayerNotifications;
    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.prayerReminders, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(context.l10n.prayerRemindersBody, style: t.bodySmall),
          const SizedBox(height: 8),
          for (var i = 0; i < kFardPrayerDefs.length; i++)
            Builder(
              builder: (context) {
                final def = kFardPrayerDefs[i];
                final key = def.name.name;
                final startOn = start[key] ?? true;
                final endOn = end[key] ?? true;
                final on = s.notificationsEnabled && (startOn || endOn);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            def.label(context.l10n),
                            style: t.bodyLarge,
                          ),
                        ),
                        Switch(
                          value: on,
                          onChanged: (v) => _setPrayer(s, key, v),
                        ),
                      ],
                    ),
                    if (on)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            JzChip(
                              context.l10n.atStart,
                              selected: startOn,
                              onTap: () {
                                final m = Map<String, bool>.from(start)
                                  ..[key] = !startOn;
                                _apply(s.copyWith(startPrayerNotifications: m));
                              },
                            ),
                            JzChip(
                              context.l10n.minBeforeEnd(10),
                              selected: endOn,
                              onTap: () {
                                final m = Map<String, bool>.from(end)
                                  ..[key] = !endOn;
                                _apply(s.copyWith(perPrayerNotifications: m));
                              },
                            ),
                          ],
                        ),
                      ),
                    if (i < kFardPrayerDefs.length - 1)
                      const JzDivider(top: 2, bottom: 2),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _JamaatAlertsCard extends ConsumerWidget {
  const _JamaatAlertsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final on = ref.watch(jamaatAlertsOnProvider);
    final minutes = ref.watch(jamaatAlertMinutesProvider);
    final alertIds = ref.watch(jamaatAlertMosquesProvider);
    final primary = ref.watch(primaryMosqueProvider);
    final savedIds = ref.watch(savedMosqueIdsProvider);
    final mosques = [
      ?primary,
      ...kDemoMosques.where(
        (m) => savedIds.contains(m.id) && m.id != primary?.id,
      ),
    ];
    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.l10n.jamaatAlerts, style: t.titleMedium),
              ),
              JzChip(context.l10n.newBadge, gold: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(context.l10n.jamaatAlertsBody, style: t.bodySmall),
          const SizedBox(height: 10),
          JzSwitchRow(
            title: context.l10n.jamaatAlertsOn,
            value: on,
            onChanged: (v) => ref.read(jamaatAlertsOnProvider.notifier).set(v),
          ),
          if (on) ...[
            const JzDivider(),
            Row(
              children: [
                Expanded(
                  child: Text(context.l10n.howEarly, style: t.bodyLarge),
                ),
                PopupMenuButton<int>(
                  initialValue: minutes,
                  onSelected: (v) =>
                      ref.read(jamaatAlertMinutesProvider.notifier).set(v),
                  itemBuilder: (_) => [
                    for (final m in const [5, 10, 15, 20, 30])
                      PopupMenuItem(
                        value: m,
                        child: Text(context.l10n.minutesCount(m)),
                      ),
                  ],
                  child: JzChip(context.l10n.minutesCount(minutes), gold: true),
                ),
              ],
            ),
            const JzDivider(),
            if (mosques.isEmpty)
              Text(context.l10n.jamaatAlertsNoMosque, style: t.bodySmall)
            else
              for (final m in mosques)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: JzSwitchRow(
                    title: m.name,
                    subtitle: m.id == primary?.id
                        ? context.l10n.primaryBadge
                        : null,
                    value: alertIds.contains(m.id),
                    onChanged: (v) => ref
                        .read(jamaatAlertMosquesProvider.notifier)
                        .toggle(m.id, v),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ClassRemindersCard extends ConsumerWidget {
  const _ClassRemindersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final on = ref.watch(classRemindersOnProvider);
    final minutes = ref.watch(classReminderMinutesProvider);
    final muted = ref.watch(mutedClassesProvider);
    final appUser = ref.watch(appUserStreamProvider).value;
    final orgId = appUser?.orgId;
    final classes = ref.watch(classesForTeacherProvider).value ?? const [];

    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.l10n.classReminders, style: t.titleMedium),
              ),
              JzChip(context.l10n.newBadge, gold: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(context.l10n.classRemindersBody, style: t.bodySmall),
          const SizedBox(height: 10),
          JzSwitchRow(
            title: context.l10n.unmarkedClassAlerts,
            value: on,
            onChanged: (v) =>
                ref.read(classRemindersOnProvider.notifier).set(v),
          ),
          if (on) ...[
            const JzDivider(),
            Row(
              children: [
                Expanded(
                  child: Text(context.l10n.howEarly, style: t.bodyLarge),
                ),
                PopupMenuButton<int>(
                  initialValue: minutes,
                  onSelected: (v) =>
                      ref.read(classReminderMinutesProvider.notifier).set(v),
                  itemBuilder: (_) => [
                    for (final m in const [10, 15, 20, 30])
                      PopupMenuItem(
                        value: m,
                        child: Text(context.l10n.minCount(m)),
                      ),
                  ],
                  child: JzChip(context.l10n.minCount(minutes), gold: true),
                ),
              ],
            ),
            if (orgId != null && classes.isNotEmpty)
              for (final cl in classes) ...[
                const JzDivider(),
                JzSwitchRow(
                  title: cl.name,
                  value: !muted.contains(cl.id),
                  onChanged: (v) =>
                      ref.read(mutedClassesProvider.notifier).toggle(cl.id, !v),
                ),
              ],
          ],
        ],
      ),
    );
  }
}
