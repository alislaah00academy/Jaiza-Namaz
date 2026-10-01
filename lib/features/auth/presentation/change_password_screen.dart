import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaiza_core/jaiza_core.dart' show Validators;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/firebase_auth_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../providers/providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updatePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.passwordUpdated)));
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapGenericError(e, context.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    // The app shell already supplies the "Change password" app bar.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: JaizaSurfaceCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.changePasswordIntro,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _current,
                label: context.l10n.currentPasswordLabel,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return context.l10n.validationRequired;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _next,
                label: context.l10n.newPasswordLabel,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: (v) {
                  if (v == null || !Validators.isValidPassword(v)) {
                    return context.l10n.validationPasswordRule;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirm,
                label: context.l10n.confirmNewPasswordLabel,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                validator: (v) {
                  if (v != _next.text) return context.l10n.validationNoMatch;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: onPrimary,
                        ),
                      )
                    : Text(context.l10n.updatePasswordButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
