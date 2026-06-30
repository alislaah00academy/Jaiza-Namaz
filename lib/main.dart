// Jaiza — bootstrap: Firebase, first auth tick, Riverpod root.
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/widgets/home_widget_bridge.dart';
import 'data/models/prayer_log.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'firebase_options.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await HomeWidget.registerInteractivityCallback(homeWidgetCallback);
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationsService.instance.init();
  final prefs = await SharedPreferences.getInstance();
  final onboardingRepo = OnboardingRepository(prefs);
  // Wait until Firebase restores session to avoid auth redirect flicker.
  await FirebaseAuth.instance.authStateChanges().first;
  runApp(
    DevicePreview(
      // Device frames/dimensions picker is only useful on the web build
      // (e.g. testing in Chrome); native Android/iOS builds should never
      // show it, even in debug mode.
      enabled: kIsWeb && !kReleaseMode,
      builder: (context) => ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
        ],
        child: const JaizaNamazApp(),
      ),
    ),
  );
}
