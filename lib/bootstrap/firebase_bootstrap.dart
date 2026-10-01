import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../core/logging/app_log.dart';
import '../firebase_options.dart';
import 'env.dart';

/// Firebase start-up, in the order 03 §6 requires: initialize → App Check →
/// emulators → Firestore settings. Used by `main()` and by the home-widget
/// background isolate, so both talk to the same database the same way.
abstract final class FirebaseBootstrap {
  static bool _done = false;

  /// The app's Firestore database (D-096). Always use this (or
  /// `firestoreProvider`), never `FirebaseFirestore.instance`, which is the
  /// unused `(default)` database.
  static FirebaseFirestore get firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: Env.firestoreDatabaseId,
  );

  static FirebaseFunctions get functions =>
      FirebaseFunctions.instanceFor(region: Env.functionsRegion);

  static FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<void> init() async {
    if (_done) return;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await _activateAppCheck();
    if (Env.useEmulators) await _connectEmulators();
    // Offline-first marking (D-070); web needs persistence turned on.
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _done = true;
  }

  /// App Check runs in **monitor mode** for now: the client always sends
  /// tokens, and enforcement is switched on later in the console (15 §9).
  /// Debug builds use debug providers — register each developer's debug token
  /// in the console (App Check → app → Manage debug tokens).
  static Future<void> _activateAppCheck() async {
    WebProvider? web;
    if (kIsWeb) {
      if (kDebugMode) {
        web = WebDebugProvider(
          debugToken: Env.appCheckWebDebugToken.isEmpty
              ? null
              : Env.appCheckWebDebugToken,
        );
      } else if (Env.recaptchaSiteKey.isNotEmpty) {
        web = ReCaptchaEnterpriseProvider(Env.recaptchaSiteKey);
      } else {
        appLog('App Check: no RECAPTCHA_SITE_KEY, skipping on web');
        return;
      }
    }
    try {
      await FirebaseAppCheck.instance.activate(
        providerWeb: web,
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
    } catch (e, st) {
      // Monitor mode: a failed activation must never block the app.
      appLog('App Check activation failed', error: e, stackTrace: st);
    }
  }

  static Future<void> _connectEmulators() async {
    final host = Env.emulatorHost.isNotEmpty
        ? Env.emulatorHost
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2'
              : 'localhost');
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    firestore.useFirestoreEmulator(host, 8080);
    functions.useFunctionsEmulator(host, 5001);
    await storage.useStorageEmulator(host, 9199);
    appLog('Using Firebase emulators at $host');
  }
}
