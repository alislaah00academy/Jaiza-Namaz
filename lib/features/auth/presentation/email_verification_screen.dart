import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/errors/firebase_auth_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jaiza_lottie.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../providers/providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _busy = false;
  bool _sent = false;

  Future<void> _checkVerified() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).reloadUser();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified && mounted) {
        context.go('/app/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email not verified yet. Open the link we sent, then try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) {
        setState(() => _sent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? mapGenericError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: AuthMaxWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const JaizaAuthHeader(),
                  const SizedBox(height: 8),
                  const Center(
                    child: JaizaLottie(
                      asset: JaizaAnims.email,
                      width: 140,
                      height: 140,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  JaizaSurfaceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'We sent a verification link to:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the link in the email, then press “I’ve verified” below.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _busy ? null : _checkVerified,
                    child: _busy
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onPrimary,
                            ),
                          )
                        : const Text('I’ve verified'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    style: AppTheme.tonalButtonStyle(context),
                    onPressed: _busy ? null : _resend,
                    child: Text(_sent ? 'Resend again' : 'Resend email'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : _signOut,
                    child: const Text('Sign out'),
                  ),
                  const SizedBox(height: 16),
                  const JaizaMosqueSkyline(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
