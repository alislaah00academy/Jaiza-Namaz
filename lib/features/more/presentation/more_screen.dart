import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../core/widgets/language_card.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import '../../nawafil/presentation/nawafil_screen.dart';
import '../../parent/presentation/family_widgets.dart';
import '../../qaza/data/qaza_tracker.dart';
import '../../../core/l10n/l10n.dart';

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
    final user = ref.watch(appUserStreamProvider).value;
    final qaza = ref.watch(qazaOverviewProvider);
    final nawafilOn = user?.nawafilEnabled ?? false;
    final isParent = ref.watch(isParentProvider);
    final children = ref.watch(childrenStreamProvider).value ?? const [];
    final isOrg = user?.role == UserRole.organization;
    final isTeacher = user?.orgMemberRole == OrgMemberRole.teacher;
    final myClasses = isTeacher
        ? ref.watch(classesForTeacherProvider).value ?? const []
        : const [];

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
        JzPageTitle(context.l10n.titleMore),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isOrg) ...[
                JzSectionLabel(
                  isTeacher
                      ? context.l10n.sectionMadrasa
                      : context.l10n.sectionOrganization,
                ),
                group([
                  JzListRow(
                    leading: icon(Icons.school_outlined),
                    title:
                        ref.watch(myOrgByIdProvider).value?.name ??
                        context.l10n.sectionOrganization,
                    subtitle: context.l10n.moreOrgSubtitle,
                    trailing: const JzChevron(),
                    showDivider: isTeacher,
                    onTap: () => context.go('/app/org'),
                  ),
                  if (isTeacher)
                    JzListRow(
                      leading: icon(Icons.class_outlined),
                      title: context.l10n.myClasses,
                      subtitle: myClasses.isEmpty
                          ? context.l10n.noClassesYet
                          : myClasses.map((c) => c.name).join(' · '),
                      trailing: const JzChevron(),
                      onTap: () => context.go('/app/org'),
                    ),
                ]),
                const SizedBox(height: 20),
              ],
              if (isParent) ...[
                JzSectionLabel(context.l10n.titleFamily),
                group([
                  JzListRow(
                    leading: icon(Icons.family_restroom_outlined),
                    title: context.l10n.titleFamily,
                    subtitle: children.isEmpty
                        ? context.l10n.addYourChildren
                        : context.l10n.moreFamilySubtitle,
                    trailing: const JzChevron(),
                    showDivider: true,
                    onTap: () => context.push('/app/family'),
                  ),
                  JzListRow(
                    leading: icon(Icons.notifications_active_outlined),
                    title: context.l10n.titleFamilyReminders,
                    subtitle: context.l10n.moreFamilyRemindersSubtitle,
                    trailing: const JzChevron(),
                    onTap: () => context.push('/app/family/reminders'),
                  ),
                ]),
                const SizedBox(height: 20),
              ],
              JzSectionLabel(context.l10n.sectionAccount),
              group([
                JzListRow(
                  leading: icon(Icons.person_outline_rounded),
                  title: context.l10n.titleProfile,
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
              JzSectionLabel(context.l10n.sectionApp),
              group([
                JzListRow(
                  leading: icon(Icons.notifications_none_rounded),
                  title: context.l10n.titleNotificationsWidgets,
                  subtitle: isParent
                      ? context.l10n.moreNotificationsParentSubtitle
                      : context.l10n.moreNotificationsSubtitle,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/widget-settings'),
                ),
                JzListRow(
                  leading: icon(Icons.history_edu_outlined),
                  title: context.l10n.qazaPlan,
                  subtitle: context.l10n.qazaRemaining(jzCount(qaza.remaining)),
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/qaza'),
                ),
                JzListRow(
                  leading: icon(Icons.front_hand_outlined),
                  title: context.l10n.titleNawafil,
                  subtitle: nawafilOn
                      ? context.l10n.trackingOn
                      : context.l10n.trackingOff,
                  trailing: const JzChevron(),
                  onTap: () => _showNawafilSheet(context, ref),
                ),
              ]),
              const SizedBox(height: 20),
              JzCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        icon(Icons.dark_mode_outlined),
                        const SizedBox(width: 14),
                        Text(
                          context.l10n.appearanceTitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    JzSegmented<ThemeMode>(
                      options: {
                        ThemeMode.light: context.l10n.themeLight,
                        ThemeMode.dark: context.l10n.themeDark,
                        ThemeMode.system: context.l10n.themeAuto,
                      },
                      selected: ref.watch(themeModeProvider),
                      onChanged: (m) =>
                          ref.read(themeModeProvider.notifier).set(m),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const LanguageCard(),
              const SizedBox(height: 20),
              JzSectionLabel(context.l10n.titleAboutJaiza),
              group([
                JzListRow(
                  leading: icon(Icons.menu_book_outlined),
                  title: context.l10n.fazailOfPrayers,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/benefits'),
                ),
                JzListRow(
                  leading: icon(Icons.info_outline_rounded),
                  title: context.l10n.aboutJaizaAndAcademy,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/about'),
                ),
                JzListRow(
                  leading: icon(Icons.call_outlined),
                  title: context.l10n.contactUs,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/contact'),
                ),
                JzListRow(
                  leading: icon(Icons.volunteer_activism_outlined),
                  title: context.l10n.titleDonation,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/donation'),
                ),
              ]),
              const SizedBox(height: 20),
              group([
                JzListRow(
                  leading: icon(Icons.lock_reset_outlined),
                  title: context.l10n.titleChangePassword,
                  trailing: const JzChevron(),
                  onTap: () => context.push('/app/change-password'),
                ),
                JzListRow(
                  leading: icon(Icons.logout_rounded),
                  title: context.l10n.actionSignOut,
                  onTap: () => _signOut(context, ref),
                ),
                JzListRow(
                  leading: icon(Icons.delete_outline_rounded, c.error),
                  title: context.l10n.deleteAccount,
                  titleColor: c.error,
                  subtitle: context.l10n.deleteAccountSubtitle,
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
              ref.watch(appUserStreamProvider).value?.nawafilEnabled ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ctx.l10n.titleNawafil, style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(ctx.l10n.nawafilSheetBody, style: t.bodyMedium),
              const SizedBox(height: 18),
              JzSwitchRow(
                title: ctx.l10n.trackNawafil,
                subtitle: ctx.l10n.trackNawafilSubtitle,
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
                  child: Text(ctx.l10n.openTodaysNawafil),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The word typed to confirm deletion. Kept in Latin letters in every
/// language so it is the same everywhere (D-024).
const _kDeleteWord = 'DELETE';

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
    final l10n = context.l10n;
    final ready = _confirm.text.trim() == _kDeleteWord;
    final lost = [
      l10n.deleteLostPrayerRecord,
      l10n.deleteLostQazaList,
      l10n.deleteLostMosques,
      l10n.deleteLostChildren,
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
                  Text(l10n.deleteAccountTitle, style: t.headlineSmall),
                  Text(l10n.cannotBeUndone, style: t.bodySmall),
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
          TextSpan(
            text: l10n.deleteTypePrefix,
            children: [
              const TextSpan(
                text: _kDeleteWord,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: l10n.deleteTypeSuffix),
            ],
          ),
          style: t.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirm,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: _kDeleteWord),
        ),
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: c.error,
            foregroundColor: c.onError,
          ),
          onPressed: ready
              ? () {
                  AppSnackBar.error(context, l10n.deleteNotConnected);
                  Navigator.pop(context);
                }
              : null,
          child: Text(l10n.deleteMyAccount),
        ),
        const SizedBox(height: 10),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.keepMyAccount),
        ),
      ],
    );
  }
}
