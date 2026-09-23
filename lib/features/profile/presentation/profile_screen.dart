import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
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

  Future<void> _save(String uid) async {
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
      if (mounted) AppSnackBar.success(context, 'Profile saved.');
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not save profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        final c = Theme.of(context).colorScheme;
        final t = Theme.of(context).textTheme;
        final isIndividual = u?.role == UserRole.individual || u?.role == null;

        Widget gap() => const SizedBox(height: 16);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => showProfilePhotoSheet(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const JzAvatar(
                      icon: Icons.person_outline_rounded,
                      size: 92,
                      iconSize: 46,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primary,
                          border: Border.all(color: c.surface, width: 2.5),
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 15,
                          color: c.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _name.text.isEmpty ? 'Your profile' : _name.text,
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
            Text(
              'Tap the camera to change your photo',
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            gap(),
            TextField(
              controller: _email,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            gap(),
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            gap(),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            gap(),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            if (u == null) ...[
              const SizedBox(height: 12),
              Text(
                'Complete your profile — your document will be created on save.',
                style: t.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : () => _save(uid),
              child: _loading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onPrimary,
                      ),
                    )
                  : const Text('Save'),
            ),
            const SizedBox(height: 24),
            JzCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Appearance', style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Switch between light and dark to check both — this '
                    'overrides your device setting.',
                    style: t.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  JzSegmented<ThemeMode>(
                    options: const {
                      ThemeMode.light: 'Light',
                      ThemeMode.dark: 'Dark',
                      ThemeMode.system: 'System',
                    },
                    selected: ref.watch(themeModeProvider),
                    onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
                  ),
                ],
              ),
            ),
            // Individuals reach these from More; Parent/Organization keep
            // them here.
            if (!isIndividual) ...[
              const SizedBox(height: 24),
              JzCard(
                child: Column(
                  children: [
                    JzListRow(
                      leading: Icon(
                        Icons.lock_reset_outlined,
                        color: c.primary,
                      ),
                      title: 'Change password',
                      trailing: const JzChevron(),
                      showDivider: true,
                      onTap: () => context.push('/app/change-password'),
                    ),
                    JzListRow(
                      leading: Icon(Icons.logout_rounded, color: c.error),
                      title: 'Sign out',
                      titleColor: c.error,
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// "Profile photo" source picker.
Future<void> showProfilePhotoSheet(BuildContext context) {
  void notYet(BuildContext ctx) {
    AppSnackBar.success(
      ctx,
      'Profile photos arrive with photo storage — coming soon.',
    );
    Navigator.pop(ctx);
  }

  return showJzSheet<void>(
    context,
    builder: (ctx) {
      final t = Theme.of(ctx).textTheme;
      final c = Theme.of(ctx).colorScheme;
      final divider = Divider(height: 1, indent: 70, color: c.outlineVariant);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Profile photo', style: t.headlineSmall),
          const SizedBox(height: 4),
          Text('Choose where the picture comes from.', style: t.bodyMedium),
          const SizedBox(height: 12),
          JzListRow(
            leading: const JzAvatar(icon: Icons.photo_camera_outlined),
            title: 'Take a photo',
            subtitle: 'Open the camera',
            trailing: const JzChevron(),
            onTap: () => notYet(ctx),
          ),
          divider,
          JzListRow(
            leading: const JzAvatar(icon: Icons.photo_library_outlined),
            title: 'Choose from gallery',
            subtitle: 'Pick an existing picture',
            trailing: const JzChevron(),
            onTap: () => notYet(ctx),
          ),
          divider,
          JzListRow(
            leading: const JzAvatar(icon: Icons.no_photography_outlined),
            title: 'Remove current photo',
            subtitle: 'Go back to the default avatar',
            trailing: const JzChevron(),
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
