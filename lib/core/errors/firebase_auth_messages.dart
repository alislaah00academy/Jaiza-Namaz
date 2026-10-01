import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/l10n.dart';
import 'error_mapper.dart';

/// Maps [FirebaseAuthException.code] to user-facing copy (no technical jargon).
String mapFirebaseAuthMessage(FirebaseAuthException e, L10n l) {
  return switch (e.code) {
    'wrong-password' || 'invalid-credential' => l.authErrorWrongPassword,
    'user-not-found' => l.authErrorUserNotFound,
    'email-already-in-use' => l.authErrorEmailInUse,
    'invalid-email' => l.authErrorInvalidEmail,
    'network-request-failed' => l.errorNetwork,
    'too-many-requests' => l.authErrorTooManyRequests,
    'user-disabled' => l.authErrorUserDisabled,
    'requires-recent-login' => l.authErrorRecentLogin,
    'weak-password' || 'password-does-not-meet-requirements' =>
      l.authErrorWeakPassword,
    'no-email' => l.authErrorNoEmail,
    _ => l.errorGeneric,
  };
}

/// Maps any error to a safe snackbar/dialog string.
String mapGenericError(Object error, L10n l) {
  error = unwrapError(error);
  if (error is FirebaseAuthException) return mapFirebaseAuthMessage(error, l);
  return l.errorGeneric;
}
