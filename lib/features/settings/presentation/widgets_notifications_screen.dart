import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/home_widget_bridge.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../features/settings/data/prayer_settings.dart';
import '../../../providers/providers.dart';
import '../../../services/location_service.dart';
import '../../../services/notifications_service.dart';

/// Calculation method, location, and notification toggles for widgets + reminders.
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
      if (mounted) {
        AppSnackBar.error(context, '$e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveManualFromFields(PrayerSettingsParsed base) async {
    final lat = double.tryParse(_lat.text.trim());
    final lon = double.tryParse(_lon.text.trim());
    if (lat == null || lon == null) {
      AppSnackBar.error(context, 'Enter valid latitude and longitude');
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

  Future<void> _onMasterNotificationsChanged(
    PrayerSettingsParsed settings,
    bool value,
  ) async {
    if (value) {
      final ok = await NotificationsService.instance
          .requestNotificationPermission();
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.error(
          context,
          'Notifications blocked — open system settings to enable.',
        );
        return;
      }
    }
    await _apply(settings.copyWith(notificationsEnabled: value));
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final settings = ref.watch(prayerSettingsProvider);

    if (uid == null) {
      return const Center(child: Text('Sign in required'));
    }

    if (!_seeded) {
      _lat.text = settings.manualLat.toString();
      _lon.text = settings.manualLon.toString();
      _label.text = settings.manualLabel;
      _seeded = true;
    }

    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Widgets & notifications',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Home-screen prayer times, GPS/manual location, and reminders when a '
          'prayer window ends.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (_saving) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 20),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Home widgets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Three widgets are available from the launcher: Prayer Tracker '
                '(4x2), Prayer Times (4x3), and Today’s Prayers dashboard '
                '(4x4). Use Refresh widgets now after changing location or '
                'calculation settings.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await HomeWidgetBridge.syncAllWidgets(ref);
                  if (context.mounted) {
                    AppSnackBar.success(context, 'Widgets refreshed');
                  }
                },
                child: const Text('Refresh widgets now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use my current location'),
                value: settings.useGps,
                onChanged: (v) => _apply(settings.copyWith(useGps: v)),
              ),
              if (!settings.useGps) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _lat,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lon,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _label,
                  decoration: const InputDecoration(labelText: 'Place label'),
                  onSubmitted: (_) => _saveManualFromFields(settings),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _saveManualFromFields(settings),
                  child: const Text('Save manual location'),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () async {
                  final pos = await LocationService.getCurrentPosition();
                  if (!context.mounted) return;
                  if (pos == null) {
                    AppSnackBar.error(
                      context,
                      'Could not get location (permission or services off).',
                    );
                    return;
                  }
                  await _apply(
                    settings.copyWith(
                      manualLat: pos.lat,
                      manualLon: pos.lon,
                      manualLabel: pos.label ?? settings.manualLabel,
                    ),
                  );
                  if (!context.mounted) return;
                  setState(() {
                    _lat.text = pos.lat.toString();
                    _lon.text = pos.lon.toString();
                    if (pos.label != null) _label.text = pos.label!;
                  });
                  AppSnackBar.success(context, 'Location detected');
                },
                child: const Text('Detect now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Calculation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue:
                    PrayerSettingsParsed.calcMethodOptions.contains(
                      settings.calcMethod,
                    )
                    ? settings.calcMethod
                    : PrayerSettingsParsed.calcMethodOptions.first,
                decoration: const InputDecoration(labelText: 'Method'),
                items: [
                  for (final k in PrayerSettingsParsed.calcMethodOptions)
                    DropdownMenuItem(
                      value: k,
                      child: Text(PrayerSettingsParsed.calcMethodLabel(k)),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) _apply(settings.copyWith(calcMethod: v));
                },
              ),
              const SizedBox(height: 16),
              Text('Madhab', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'hanafi', label: Text('Hanafi')),
                  ButtonSegment(value: 'shafi', label: Text('Shafi’i')),
                ],
                selected: {settings.madhab},
                onSelectionChanged: (s) {
                  final m = s.first;
                  _apply(settings.copyWith(madhab: m));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Start alerts fire when prayer time begins. End reminders fire '
                '10 minutes before the window ends and are cancelled when you '
                'mark the prayer as prayed.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable reminders'),
                value: settings.notificationsEnabled,
                onChanged: (v) => _onMasterNotificationsChanged(settings, v),
              ),
              ..._perPrayerTile(settings, 'fajr', 'Fajr'),
              ..._perPrayerTile(settings, 'zuhr', 'Zuhr'),
              ..._perPrayerTile(settings, 'asr', 'Asr'),
              ..._perPrayerTile(settings, 'maghrib', 'Maghrib'),
              ..._perPrayerTile(settings, 'isha', 'Isha'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JaizaSurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Debug', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await NotificationsService.instance.scheduleTestIn(
                    const Duration(seconds: 30),
                  );
                  if (context.mounted) {
                    AppSnackBar.success(
                      context,
                      'Test notification in 30 seconds',
                    );
                  }
                },
                child: const Text('Send test notification in 30 s'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await HomeWidgetBridge.syncAllWidgets(ref);
                  if (context.mounted) {
                    AppSnackBar.success(context, 'Widgets refreshed');
                  }
                },
                child: const Text('Refresh widgets now'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _perPrayerTile(
    PrayerSettingsParsed settings,
    String key,
    String label,
  ) {
    final endMap = Map<String, bool>.from(settings.perPrayerNotifications);
    final startMap = Map<String, bool>.from(settings.startPrayerNotifications);
    final startOn = startMap[key] ?? true;
    final endOn = endMap[key] ?? true;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('At start time'),
        value: startOn && settings.notificationsEnabled,
        onChanged: settings.notificationsEnabled
            ? (v) {
                startMap[key] = v;
                _apply(settings.copyWith(startPrayerNotifications: startMap));
              }
            : null,
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('10 minutes before end if not prayed'),
        value: endOn && settings.notificationsEnabled,
        onChanged: settings.notificationsEnabled
            ? (v) {
                endMap[key] = v;
                _apply(settings.copyWith(perPrayerNotifications: endMap));
              }
            : null,
      ),
    ];
  }
}
