import 'dart:developer' as developer;

/// Lightweight debug logging for Firebase and app errors.
void appLog(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'JaizaNamaz',
    error: error,
    stackTrace: stackTrace,
  );
}
