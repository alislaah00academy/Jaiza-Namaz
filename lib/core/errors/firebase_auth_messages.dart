import 'package:firebase_auth/firebase_auth.dart';

/// Maps [FirebaseAuthException.code] to user-facing copy (no technical jargon).
String mapFirebaseAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-credential':
      return 'Incorrect password. Please try again.';
    case 'user-not-found':
      return 'No account found.';
    case 'email-already-in-use':
      return 'Email already registered.';
    case 'invalid-email':
      return 'Please enter a valid email.';
    case 'network-request-failed':
      return 'Check your connection and try again.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'requires-recent-login':
      return 'Please sign in again to continue.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// Maps any error to a safe snackbar/dialog string.
String mapGenericError(Object error) {
  if (error is FirebaseAuthException) {
    return mapFirebaseAuthMessage(error);
  }
  return 'Something went wrong. Please try again.';
}
