import 'dart:developer' as developer;

/// Where `appLog` errors go besides the debug console. Set by
/// `CrashReporting.init()` so release builds record them as Crashlytics
/// non-fatals (03 §7). `null` in tests and before start-up.
void Function(String message, Object error, StackTrace? stackTrace)? appLogSink;

/// App logging — use this, never `print` (18 §2).
void appLog(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'JaizaNamaz',
    error: error,
    stackTrace: stackTrace,
  );
  if (error != null) appLogSink?.call(message, error, stackTrace);
}
