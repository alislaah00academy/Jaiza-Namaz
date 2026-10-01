import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaiza_core/jaiza_core.dart' show Validators;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/errors/firebase_auth_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.initialRole});

  /// Role picked on `/get-started`, carried in via the `?role=` query param.
  /// Null means the signup link was opened directly (e.g. a legacy bookmark)
  /// — those accounts fall back to the post-verification `/select-role` step.
  final UserRole? initialRole;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _institutionName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  bool get _isOrganization => widget.initialRole == UserRole.organization;

  @override
  void dispose() {
    _name.dispose();
    _institutionName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _email.text,
            password: _password.text,
            name: _name.text.trim(),
          );
      final user = cred.user!;
      await ref
          .read(userRepositoryProvider)
          .createUserProfile(user: user, name: _name.text.trim());
      await ref.read(streakRepositoryProvider).ensureStreakDoc(user.uid);
      final claimedTeacherInvite = await _claimPendingOrgInviteIfAny(user);
      // An explicit teacher invite always wins over whatever the user picked
      // on /get-started — they're joining an existing org, not starting one.
      if (!claimedTeacherInvite && widget.initialRole != null) {
        await _applyInitialRole(user, widget.initialRole!);
      }
      if (mounted) context.go('/verify-email');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapGenericError(e, context.l10n))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapGenericError(e, context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// If an org admin has invited this email as a teacher, auto-attach this
  /// account to that org so [app_router.dart]'s role redirect skips
  /// `/select-role` entirely. Returns true if an invite was claimed.
  Future<bool> _claimPendingOrgInviteIfAny(User user) async {
    final email = user.email;
    if (email == null || email.isEmpty) return false;
    final orgId = await ref
        .read(organizationRepositoryProvider)
        .claimInviteIfAny(
          email: email,
          uid: user.uid,
          name: user.displayName ?? email,
        );
    if (orgId == null) return false;
    await ref
        .read(userRepositoryProvider)
        .attachAsOrgTeacher(uid: user.uid, orgId: orgId);
    return true;
  }

  /// Sets the role chosen on `/get-started`. For Organization, the institute
  /// name was already collected inline on this form (see `_institutionName`)
  /// — no separate post-submit dialog needed.
  Future<void> _applyInitialRole(User user, UserRole role) async {
    if (role == UserRole.organization) {
      final orgId = await ref
          .read(organizationRepositoryProvider)
          .createOrganization(
            adminUid: user.uid,
            name: _institutionName.text.trim(),
          );
      await ref
          .read(userRepositoryProvider)
          .setRole(
            uid: user.uid,
            role: UserRole.organization,
            orgId: orgId,
            orgMemberRole: OrgMemberRole.admin,
          );
    } else {
      await ref.read(userRepositoryProvider).setRole(uid: user.uid, role: role);
    }
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: AuthMaxWidth(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  JaizaAuthHeader(onBack: () => _back(context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.signupTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.signupSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AuthTextField(
                                  controller: _name,
                                  label: context.l10n.fullNameLabel,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return context.l10n.validationEnterName;
                                    }
                                    return null;
                                  },
                                ),
                                if (_isOrganization) ...[
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _institutionName,
                                    label: context.l10n.instituteNameLabel,
                                    hint: context.l10n.instituteNameHint,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return context.l10n.validationEnterInstitute;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: _email,
                                  label: context.l10n.emailLabel,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return context.l10n.validationEnterEmail;
                                    }
                                    if (!v.contains('@')) {
                                      return context.l10n.validationValidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: _password,
                                  label: context.l10n.passwordLabel,
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
                                  label: context.l10n.confirmPasswordLabel,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  validator: (v) {
                                    if (v != _password.text) {
                                      return context.l10n.validationPasswordsNoMatch;
                                    }
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
                                      : Text(context.l10n.signUpButton),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
