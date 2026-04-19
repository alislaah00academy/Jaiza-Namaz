import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/firebase_auth_messages.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'We sent a verification link to:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap the link in the email, then press “I’ve verified” below.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _checkVerified,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('I’ve verified'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _resend,
                child: Text(_sent ? 'Resend again' : 'Resend email'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
