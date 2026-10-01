import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/errors/firebase_auth_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/role_home_route.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await ref
          .read(authRepositoryProvider)
          .signIn(email: _email.text, password: _password.text);
      await ref.read(userRepositoryProvider).syncFromAuth(cred.user!);
      await ref.read(streakRepositoryProvider).ensureStreakDoc(cred.user!.uid);
      var appUser = await ref
          .read(userRepositoryProvider)
          .watchUser(cred.user!.uid)
          .first;
      appUser = await _maybeClaimPendingOrgInvite(cred.user!, appUser);
      if (mounted) {
        final u = cred.user!;
        if (u.emailVerified) {
          context.go(homeRouteForAppUser(appUser));
        } else {
          context.go('/verify-email');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapGenericError(e, context.l10n))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapGenericError(e, context.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// If an org admin has invited this email as a teacher, auto-attach this
  /// account to that org so [app_router.dart]'s role redirect skips
  /// `/select-role` entirely. For an account that already picked Individual
  /// or Parent, switching roles is a meaningful change — ask first instead
  /// of silently flipping their dashboard. Returns the up-to-date [AppUser]
  /// (refetched if a claim happened, otherwise the one passed in).
  Future<AppUser?> _maybeClaimPendingOrgInvite(
    User user,
    AppUser? appUser,
  ) async {
    final email = user.email;
    if (email == null || email.isEmpty) return appUser;
    final orgRepo = ref.read(organizationRepositoryProvider);
    final pending = await orgRepo.findPendingInvite(email: email);
    if (pending == null) return appUser;

    final currentRole = appUser?.role;
    final isSafeToAutoSwitch =
        currentRole == null || currentRole == UserRole.organization;

    if (!isSafeToAutoSwitch) {
      if (!mounted) return appUser;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.teacherSwitchTitle),
          content: Text(
            context.l10n.teacherSwitchBody(
              pending.orgName.isEmpty
                  ? context.l10n.anOrganization
                  : pending.orgName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.notNow),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.switchButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return appUser;
    }

    await orgRepo.claimInvite(
      orgId: pending.orgId,
      email: email,
      uid: user.uid,
      name: user.displayName ?? email,
    );
    await ref
        .read(userRepositoryProvider)
        .attachAsOrgTeacher(uid: user.uid, orgId: pending.orgId);
    return ref.read(userRepositoryProvider).watchUser(user.uid).first;
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
                          context.l10n.loginTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.loginSubtitle,
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
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return context
                                          .l10n
                                          .validationEnterPassword;
                                    }
                                    return null;
                                  },
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/reset-password'),
                                    child: Text(context.l10n.forgotPassword),
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      : Text(context.l10n.logInLower),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.l10n.newHere,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          context.push('/get-started'),
                                      child: Text(context.l10n.createAccount),
                                    ),
                                  ],
                                ),
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
