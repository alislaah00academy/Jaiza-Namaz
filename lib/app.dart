import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/l10n.dart';
import 'core/l10n/locale_provider.dart';
import 'core/local/local_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/update_gate/update_gate.dart';
import 'core/update_gate/update_required_screen.dart';
import 'core/utils/date_utils.dart';
import 'core/widgets/home_widget_bridge.dart';
import 'router/app_router.dart';

class JaizaNamazApp extends ConsumerStatefulWidget {
  const JaizaNamazApp({super.key});

  @override
  ConsumerState<JaizaNamazApp> createState() => _JaizaNamazAppState();
}

class _JaizaNamazAppState extends ConsumerState<JaizaNamazApp>
    with WidgetsBindingObserver {
  Timer? _dayRolloverTimer;
  String? _lastRescheduleDayKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastRescheduleDayKey = AppDateUtils.localDateKey(DateTime.now());
    _dayRolloverTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final k = AppDateUtils.localDateKey(DateTime.now());
      if (_lastRescheduleDayKey != k) {
        _lastRescheduleDayKey = k;
        HomeWidgetBridge.syncAllWidgets(ref);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeWidgetBridge.bootstrap(ref);
      checkUpdateGate(ref);
    });
  }

  @override
  void dispose() {
    _dayRolloverTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    HomeWidgetBridge.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeWidgetBridge.syncAllWidgets(ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    // Device Preview (web debug only) may force a locale to test Urdu/RTL.
    final locale =
        DevicePreview.locale(context) ?? ref.watch(appLanguageProvider).locale;
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      theme: AppTheme.light(locale: locale),
      darkTheme: AppTheme.dark(locale: locale),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      builder: (context, child) => DevicePreview.appBuilder(
        context,
        // Support system text scaling up to 2.0 (16 §3.2 rule 8).
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 2.0,
          child: ref.watch(updateRequiredProvider)
              ? const UpdateRequiredScreen()
              : child!,
        ),
      ),
    );
  }
}
