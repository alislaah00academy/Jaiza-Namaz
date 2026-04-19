import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
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

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Firestore path: users / $uid',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
            if (u == null)
              Text(
                'Complete your profile — your document will be created on save.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        await ref.read(userRepositoryProvider).updateProfile(
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
                          AppSnackBar.error(context, 'Could not save profile.');
                        }
                      } finally {
                        if (context.mounted) setState(() => _loading = false);
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
