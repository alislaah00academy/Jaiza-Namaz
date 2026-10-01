import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../core/logging/app_log.dart';

/// Crash reporting (D-074). Crashlytics on Android/iOS; it doesn't support
/// web, so web errors are sent to Analytics as `app_error` events instead
/// (no personal data: only the error type and where it happened).
abstract final class CrashReporting {
  static bool get _crashlytics => !kIsWeb;

  static Future<void> init() async {
    if (_crashlytics) {
      final c = FirebaseCrashlytics.instance;
      await c.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = c.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        c.recordError(error, stack, fatal: true);
        return true;
      };
    } else {
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        previous?.call(details);
        _webError(details.exception, 'flutter');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        appLog('Uncaught error', error: error, stackTrace: stack);
        _webError(error, 'platform');
        return true;
      };
    }
    appLogSink = recordNonFatal;
  }

  /// Non-fatal errors from `appLog(..., error: e)` in release builds.
  static void recordNonFatal(String message, Object error, StackTrace? stack) {
    if (kDebugMode) return;
    // Wrong passwords, taken emails etc. are user input, not app bugs.
    if (error is FirebaseAuthException) return;
    if (_crashlytics) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, reason: message),
      );
    } else {
      _webError(error, 'log');
    }
  }

  static void _webError(Object error, String where) {
    if (kDebugMode) return;
    unawaited(
      FirebaseAnalytics.instance
          .logEvent(
            name: 'app_error',
            parameters: {'code': error.runtimeType.toString(), 'where': where},
          )
          .catchError((_) {}),
    );
  }
}
