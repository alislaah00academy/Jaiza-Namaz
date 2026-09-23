import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../../nawafil/presentation/nawafil_screen.dart';
import '../../parent/presentation/family_widgets.dart';
import '../../qaza/data/qaza_tracker.dart';

/// More tab — everything that is not daily: account, app settings, content,
/// and account actions.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final user = ref.watch(appUserStreamProvider).valueOrNull;
    final qaza = ref.watch(qazaOverviewProvider);
    final nawafilOn = user?.nawafilEnabled ?? false;
    final isParent = ref.watch(isParentProvider);
    final children = ref.watch(childrenStreamProvider).valueOrNull ?? const [];

    Widget icon(IconData i, [Color? color]) =>
        Icon(i, color: color ?? c.primary);

    Widget group(List<Widget> rows) => JzCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, indent: 54, color: c.outlineVariant),
          ],
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const JzPageTitle('More'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isParent) ...[
                const JzSectionLabel('Family'),
                group([
                  JzListRow(
                    leading: icon(Icons.family_restroom_outlined),
                    title: 'Family',
                    subtitle: children.isEmpty
                        ? 'Add your children'
                        : 'Children, progress and their reminders',
                    trailing: const JzChevron(),
                    showDivider: true,
                    onTap: () => context.push('/app/family'),
                  ),
                  JzListRow(
                    leading: icon(Icons.notifications_active_outlined),
                    title: 'Family reminders',
                    subtitle: 'Nudges when a prayer isn’t marked',
                    trailing: const JzChevron(),
                    onTap: () => context.push('/app/family/reminders'),
                  ),
                ]),
                const SizedBox(height: 20),
              ],
              const JzSectionLabel('Account'),
              group([
                JzListRow(
                  leading: icon(Icons.person_outline_rounded),
                  title: 'Profile',
                  subtitle: user == null
                      ? null
                      : [
                          user.name,
                          user.email,
                        ].where((s) => s.trim().isNotEmpty).join(' · '),
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/profile'),
                ),
              ]),
              const SizedBox(height: 20),
              const JzSectionLabel('App'),
              group([
                JzListRow(
                  leading: icon(Icons.notifications_none_rounded),
                  title: 'Notifications & widgets',
                  subtitle: isParent
                      ? 'Your prayers, Jama’at, widgets'
                      : 'Reminders, Jama’at alerts, location',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/widget-settings'),
                ),
                JzListRow(
                  leading: icon(Icons.history_edu_outlined),
                  title: 'Qaza plan',
                  subtitle: '${jzCount(qaza.remaining)} remaining',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/qaza'),
                ),
                JzListRow(
                  leading: icon(Icons.front_hand_outlined),
                  title: 'Nawafil',
                  subtitle: nawafilOn ? 'Tracking on' : 'Tracking off',
                  trailing: const JzChevron(),
                  onTap: () => _showNawafilSheet(context, ref),
                ),
              ]),
              const SizedBox(height: 20),
              const JzSectionLabel('About Jaiza'),
              group([
                JzListRow(
                  leading: icon(Icons.menu_book_outlined),
                  title: 'Fazail of prayers',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/benefits'),
                ),
                JzListRow(
                  leading: icon(Icons.info_outline_rounded),
                  title: 'About Jaiza & Al Islaah Academy',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/about'),
                ),
                JzListRow(
                  leading: icon(Icons.call_outlined),
                  title: 'Contact us',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/contact'),
                ),
                JzListRow(
                  leading: icon(Icons.volunteer_activism_outlined),
                  title: 'Donation',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/donation'),
                ),
              ]),
              const SizedBox(height: 20),
              group([
                JzListRow(
                  leading: icon(Icons.lock_reset_outlined),
                  title: 'Change password',
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/change-password'),
                ),
                JzListRow(
                  leading: icon(Icons.logout_rounded),
                  title: 'Sign out',
                  onTap: () => _signOut(context, ref),
                ),
                JzListRow(
                  leading: icon(Icons.delete_outline_rounded, c.error),
                  title: 'Delete account',
                  titleColor: c.error,
                  subtitle: 'Removes your record permanently',
                  trailing: const JzChevron(),
                  onTap: () => showDeleteAccountSheet(context),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _showNawafilSheet(BuildContext context, WidgetRef ref) {
    showJzSheet<void>(
      context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final t = Theme.of(ctx).textTheme;
          final on =
              ref.watch(appUserStreamProvider).valueOrNull?.nawafilEnabled ??
              false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nawafil', style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Track Tahajjud, Ishraq, Chasht, Awwabin, Rawatib and Taraweeh '
                'alongside your Fard. Nawafil are never counted as Qaza.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 18),
              JzSwitchRow(
                title: 'Track Nawafil',
                subtitle: 'Shows a Nawafil card on Today',
                value: on,
                onChanged: (v) => setNawafilEnabled(ctx, ref, v),
              ),
              const SizedBox(height: 18),
              if (on)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/app/nawafil');
                  },
                  child: const Text('Open today’s Nawafil'),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// "Delete your account?" confirmation sheet.
Future<void> showDeleteAccountSheet(BuildContext context) {
  return showJzSheet<void>(
    context,
    builder: (ctx) => const _DeleteAccountSheet(),
  );
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final ready = _confirm.text.trim() == 'DELETE';
    const lost = [
      'Your prayer record and streaks',
      'Your Qaza list',
      'Saved mosques and Jama’at alerts',
      'Children you added, and their records',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const JzAvatar(
              icon: Icons.delete_outline_rounded,
              size: 38,
              iconSize: 20,
              tone: JzAvatarTone.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete your account?', style: t.headlineSmall),
                  Text('This cannot be undone.', style: t.bodySmall),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        JzCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (final l in lost)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        size: 18,
                        color: c.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l, style: t.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          const TextSpan(
            text: 'Type ',
            children: [
              TextSpan(
                text: 'DELETE',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' to confirm.'),
            ],
          ),
          style: t.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirm,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'DELETE'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: c.error,
            foregroundColor: c.onError,
          ),
          onPressed: ready
              ? () {
                  AppSnackBar.error(
                    context,
                    'Account deletion is not connected yet — please contact '
                    'Al Islaah Academy to remove your data.',
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Delete my account'),
        ),
        const SizedBox(height: 10),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep my account'),
        ),
      ],
    );
  }
}
