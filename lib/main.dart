// Jaiza — bootstrap: Firebase, first auth tick, Riverpod root.
import 'package:device_preview/device_preview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'bootstrap/crash_reporting.dart';
import 'bootstrap/firebase_bootstrap.dart';
import 'core/analytics/analytics.dart';
import 'core/errors/error_mapper.dart';
import 'core/local/local_prefs.dart';
import 'core/widgets/home_widget_bridge.dart';
import 'data/models/prayer_log.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'providers/providers.dart';
import 'services/notifications_service.dart';

@pragma('vm:entry-point')
Future<void> homeWidgetCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme != JaizaWidgetUri.scheme ||
      uri.host != JaizaWidgetUri.host ||
      uri.path != JaizaWidgetUri.pathMark) {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  // Same database, App Check and emulator wiring as the app (03 §6).
  await FirebaseBootstrap.init();

  final uid = await HomeWidget.getWidgetData<String>(
    HomeWidgetBridge.uidKey,
    defaultValue: '',
  );
  if (uid == null || uid.isEmpty) return;

  final name = uri.queryParameters['name'];
  final status = uri.queryParameters['status'];
  if (name == null || status == null) return;

  await BackgroundWidgetWriter.applyOptimistic(
    uid: uid,
    name: name,
    status: status,
  );

  try {
    await BackgroundWidgetWriter.persist(uid: uid, name: name, status: status);
    await NotificationsService.instance.init();
    if (status == 'completed') {
      final prayer = PrayerNameX.fromFirestore(name);
      if (prayer != null) {
        await NotificationsService.instance.cancelForPrayer(
          DateTime.now(),
          prayer,
        );
      }
    }
  } catch (_) {
    // Keep widget interactivity resilient in background isolate.
  }
}

/// Start-up order from 03 §6. Network work that isn't needed for the first
/// frame (Remote Config, push) runs after it, never before.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.init();
  await CrashReporting.init();
  final prefs = await SharedPreferences.getInstance();
  // Analytics follows the Profile → Privacy switch (15 §14). Debug builds
  // never send: there is one Firebase project for dev and prod (D-003).
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
    !kDebugMode && (prefs.getBool(AnalyticsEnabledNotifier.key) ?? true),
  );
  await NotificationsService.instance.init(); // no-op on web
  if (!kIsWeb) {
    await HomeWidget.registerInteractivityCallback(homeWidgetCallback);
  }
  final onboardingRepo = OnboardingRepository(prefs);
  // Wait until Firebase restores the session to avoid redirect flicker.
  await FirebaseAuth.instance.authStateChanges().first;
  runApp(
    DevicePreview(
      // Device frames/dimensions picker is only useful on the web build
      // (e.g. testing in Chrome); native Android/iOS builds should never
      // show it, even in debug mode.
      enabled: kIsWeb && !kReleaseMode,
      builder: (context) => ProviderScope(
        retry: providerRetry,
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const JaizaNamazApp(),
      ),
    ),
  );
}
