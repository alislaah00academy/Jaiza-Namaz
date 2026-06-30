import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
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
    return MaterialApp.router(
      title: 'Jaiza',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
