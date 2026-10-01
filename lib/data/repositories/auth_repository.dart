import 'package:firebase_auth/firebase_auth.dart';

import '../../core/analytics/analytics.dart';
import '../../core/logging/app_log.dart';

/// Firebase Authentication. Errors are rethrown as-is; screens show them
/// with `mapGenericError(e, context.l10n)`.
class AuthRepository {
  AuthRepository(this._auth, {Analytics? analytics}) : _analytics = analytics;

  final FirebaseAuth _auth;
  final Analytics? _analytics;

  Stream<User?> get userChanges => _auth.userChanges();
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> waitForInitialAuthState() => _auth.authStateChanges().first;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      if (name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
        await user.reload();
      }
      await user.sendEmailVerification();
      _analytics?.signUp('password');
      return credential;
    } on FirebaseAuthException catch (e, st) {
      appLog('signUp', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _analytics?.login('password');
      return credential;
    } on FirebaseAuthException catch (e, st) {
      appLog('signIn', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e, st) {
      appLog('sendPasswordResetEmail', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user?.email == null) {
      throw FirebaseAuthException(code: 'no-email');
    }
    try {
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e, st) {
      appLog('updatePassword', error: e, stackTrace: st);
      rethrow;
    }
  }
}
