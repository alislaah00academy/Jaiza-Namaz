import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/firebase_auth_messages.dart';
import '../../core/logging/app_log.dart';

/// Firebase Authentication — maps errors to friendly messages at call sites.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get userChanges => _auth.userChanges();
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> waitForInitialAuthState() =>
      _auth.authStateChanges().first;

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
      return credential;
    } on FirebaseAuthException catch (e, st) {
      appLog('signUp', error: e, stackTrace: st);
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthMessage(e),
      );
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e, st) {
      appLog('signIn', error: e, stackTrace: st);
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthMessage(e),
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e, st) {
      appLog('sendPasswordResetEmail', error: e, stackTrace: st);
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthMessage(e),
      );
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
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'No email associated with this account.',
      );
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
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthMessage(e),
      );
    }
  }
}
