import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';
import '../../../core/l10n/l10n.dart';

/// "Invite a teacher" sheet — email only, matching the design.
Future<void> showInviteTeacherSheet(
  BuildContext context,
  WidgetRef ref,
  String orgId,
) {
  final controller = TextEditingController();
  return showJzSheet<void>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final t = Theme.of(ctx).textTheme;
        var sending = false;
        Future<void> send() async {
          final email = controller.text.trim();
          if (email.isEmpty || !email.contains('@')) {
            AppSnackBar.error(ctx, ctx.l10n.validationValidEmail);
            return;
          }
          setState(() => sending = true);
          try {
            await ref
                .read(organizationRepositoryProvider)
                .inviteTeacher(orgId: orgId, email: email);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              AppSnackBar.success(context, ctx.l10n.inviteSent(email));
            }
          } on TeacherAlreadyActiveException {
            if (ctx.mounted) {
              AppSnackBar.error(ctx, ctx.l10n.teacherAlreadyActive);
            }
          } catch (_) {
            if (ctx.mounted)
              AppSnackBar.error(ctx, ctx.l10n.couldNotSendInvite);
          } finally {
            if (ctx.mounted) setState(() => sending = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ctx.l10n.inviteATeacher, style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(ctx.l10n.inviteTeacherBody, style: t.bodyMedium),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: ctx.l10n.emailLabel,
                hintText: ctx.l10n.teacherEmailHint,
              ),
              onSubmitted: (_) => send(),
            ),
            const SizedBox(height: 14),
            JzNoteCard(body: Text(ctx.l10n.teacherPermissionsNote)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: sending ? null : send,
              child: sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(ctx.l10n.sendInvite),
            ),
          ],
        );
      },
    ),
  );
}

/// "New class" sheet — name + optional section.
Future<void> showNewClassSheet(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required String teacherUid,
  void Function(String classId)? onCreated,
}) {
  final name = TextEditingController();
  final section = TextEditingController();
  return showJzSheet<void>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final t = Theme.of(ctx).textTheme;
        var saving = false;
        Future<void> create() async {
          final n = name.text.trim();
          if (n.isEmpty) {
            AppSnackBar.error(ctx, ctx.l10n.enterClassName);
            return;
          }
          setState(() => saving = true);
          try {
            final id = await ref
                .read(organizationRepositoryProvider)
                .createClass(orgId: orgId, teacherUid: teacherUid, name: n);
            if (section.text.trim().isNotEmpty) {
              await ref
                  .read(classSectionsProvider.notifier)
                  .set(id, section.text.trim());
            }
            if (ctx.mounted) {
              Navigator.pop(ctx);
              onCreated?.call(id);
            }
          } catch (_) {
            if (ctx.mounted) {
              AppSnackBar.error(ctx, ctx.l10n.couldNotCreateClass);
            }
          } finally {
            if (ctx.mounted) setState(() => saving = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ctx.l10n.newClass, style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(ctx.l10n.newClassBody, style: t.bodyMedium),
            const SizedBox(height: 18),
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: ctx.l10n.classNameLabel,
                hintText: ctx.l10n.classNameHint,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: section,
              decoration: InputDecoration(
                labelText: ctx.l10n.sectionOptional,
                hintText: ctx.l10n.sectionHint,
              ),
              onSubmitted: (_) => create(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: saving ? null : create,
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(ctx.l10n.createClass),
            ),
          ],
        );
      },
    ),
  );
}
