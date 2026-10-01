import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

/// Riverpod 3 wraps errors thrown inside providers in [ProviderException]
/// (04 §8). Always map the original error, never the wrapper.
Object unwrapError(Object error) {
  var e = error;
  while (e is ProviderException) {
    e = e.exception;
  }
  return e;
}

/// Firebase error codes that will not fix themselves by trying again.
const _permanentCodes = {
  'permission-denied',
  'unauthenticated',
  'not-found',
  'invalid-argument',
  'failed-precondition',
  'already-exists',
};

/// `ProviderScope.retry` policy (04 §8 step 2): retry a failing provider up to
/// 3 times with 1 s, 2 s, 4 s back-off, but never for permanent Firebase
/// errors such as `permission-denied`.
Duration? providerRetry(int retryCount, Object error) {
  final e = unwrapError(error);
  if (e is FirebaseException && _permanentCodes.contains(e.code)) return null;
  if (retryCount >= 3) return null;
  return Duration(seconds: 1 << retryCount);
}
