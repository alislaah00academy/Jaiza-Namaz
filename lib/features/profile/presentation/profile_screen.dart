import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/errors/firebase_auth_messages.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../core/widgets/language_card.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import '../../../core/l10n/l10n.dart';

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
      if (mounted) AppSnackBar.success(context, context.l10n.profileSaved);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.profileSaveFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final appUserAsync = ref.watch(appUserStreamProvider);

    if (uid == null) {
      return Center(child: Text(context.l10n.signInRequired));
    }

    return appUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(mapGenericError(e, context.l10n))),
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
                    PositionedDirectional(
                      end: -2,
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
              _name.text.isEmpty ? context.l10n.yourProfile : _name.text,
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
            Text(
              context.l10n.tapCameraToChangePhoto,
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: context.l10n.nameLabel),
            ),
            gap(),
            TextField(
              controller: _email,
              readOnly: true,
              decoration: InputDecoration(labelText: context.l10n.emailLabel),
            ),
            gap(),
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: context.l10n.ageLabel),
            ),
            gap(),
            TextField(
              controller: _city,
              decoration: InputDecoration(labelText: context.l10n.cityLabel),
            ),
            gap(),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: context.l10n.phoneLabel),
            ),
            if (u == null) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.completeProfileHint,
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
                  : Text(context.l10n.actionSave),
            ),
            const SizedBox(height: 24),
            JzCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.appearanceTitle, style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.appearanceSubtitle,
                    style: t.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  JzSegmented<ThemeMode>(
                    options: {
                      ThemeMode.light: context.l10n.themeLight,
                      ThemeMode.dark: context.l10n.themeDark,
                      ThemeMode.system: context.l10n.themeSystem,
                    },
                    selected: ref.watch(themeModeProvider),
                    onChanged: (m) =>
                        ref.read(themeModeProvider.notifier).set(m),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const LanguageCard(),
            const SizedBox(height: 24),
            JzCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.privacyTitle, style: t.titleMedium),
                  const SizedBox(height: 8),
                  JzSwitchRow(
                    title: context.l10n.privacyAnalyticsTitle,
                    subtitle: context.l10n.privacyAnalyticsSubtitle,
                    value: ref.watch(analyticsEnabledProvider),
                    onChanged: (v) =>
                        ref.read(analyticsEnabledProvider.notifier).set(v),
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
                      title: context.l10n.titleChangePassword,
                      trailing: const JzChevron(),
                      showDivider: true,
                      onTap: () => context.push('/app/change-password'),
                    ),
                    JzListRow(
                      leading: Icon(Icons.logout_rounded, color: c.error),
                      title: context.l10n.actionSignOut,
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
      ctx.l10n.profilePhotosComingSoon,
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
          Text(ctx.l10n.profilePhotoTitle, style: t.headlineSmall),
          const SizedBox(height: 4),
          Text(ctx.l10n.profilePhotoSubtitle, style: t.bodyMedium),
          const SizedBox(height: 12),
          JzListRow(
            leading: const JzAvatar(icon: Icons.photo_camera_outlined),
            title: ctx.l10n.takePhoto,
            subtitle: ctx.l10n.openCamera,
            trailing: const JzChevron(),
            onTap: () => notYet(ctx),
          ),
          divider,
          JzListRow(
            leading: const JzAvatar(icon: Icons.photo_library_outlined),
            title: ctx.l10n.chooseFromGallery,
            subtitle: ctx.l10n.pickExistingPicture,
            trailing: const JzChevron(),
            onTap: () => notYet(ctx),
          ),
          divider,
          JzListRow(
            leading: const JzAvatar(icon: Icons.no_photography_outlined),
            title: ctx.l10n.removeCurrentPhoto,
            subtitle: ctx.l10n.backToDefaultAvatar,
            trailing: const JzChevron(),
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.actionCancel),
          ),
        ],
      );
    },
  );
}
