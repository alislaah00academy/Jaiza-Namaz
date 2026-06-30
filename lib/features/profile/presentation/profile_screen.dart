import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _age.dispose();
    _city.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final appUserAsync = ref.watch(appUserStreamProvider);

    if (uid == null) {
      return const Center(child: Text('Sign in required'));
    }

    return appUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (u) {
        if (u != null && !_seeded) {
          _name.text = u.name;
          _email.text = u.email;
          _age.text = u.age?.toString() ?? '';
          _city.text = u.city ?? '';
          _phone.text = u.phone ?? '';
          _seeded = true;
        }

        final onPrimary = Theme.of(context).colorScheme.onPrimary;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your profile',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Firestore path: users / $uid',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            JaizaSurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _age,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  if (u == null)
                    Text(
                      'Complete your profile — your document will be created on save.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            try {
                              await ref
                                  .read(userRepositoryProvider)
                                  .updateProfile(
                                    uid: uid,
                                    name: _name.text.trim(),
                                    email: _email.text.trim(),
                                    age: int.tryParse(_age.text),
                                    city: _city.text.trim(),
                                    phone: _phone.text.trim(),
                                  );
                              if (context.mounted) {
                                AppSnackBar.success(context, 'Profile saved.');
                              }
                            } catch (_) {
                              if (context.mounted) {
                                AppSnackBar.error(
                                  context,
                                  'Could not save profile.',
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => _loading = false);
                              }
                            }
                          },
                    child: _loading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onPrimary,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SettingsSection(role: u?.role, onSignOut: _signOut),
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.role, required this.onSignOut});

  final UserRole? role;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget tile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color,
    }) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(icon, color: color ?? scheme.primary),
          title: Text(label, style: TextStyle(color: color)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (role == UserRole.individual || role == null)
          tile(
            icon: Icons.widgets_outlined,
            label: 'Widgets & Notifications',
            onTap: () => context.push('/app/widget-settings'),
          ),
        tile(
          icon: Icons.lock_reset_outlined,
          label: 'Change password',
          onTap: () => context.push('/app/change-password'),
        ),
        tile(
          icon: Icons.logout,
          label: 'Sign out',
          color: scheme.error,
          onTap: () => onSignOut(),
        ),
      ],
    );
  }
}
