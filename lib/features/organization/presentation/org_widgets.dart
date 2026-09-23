import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../providers/providers.dart';
import '../data/org_extras.dart';

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
            AppSnackBar.error(ctx, 'Enter a valid email');
            return;
          }
          setState(() => sending = true);
          try {
            await ref
                .read(organizationRepositoryProvider)
                .inviteTeacher(orgId: orgId, email: email);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              AppSnackBar.success(
                context,
                'Invite sent. They\'ll get teacher access when they sign up '
                'or log in with $email.',
              );
            }
          } on TeacherAlreadyActiveException catch (e) {
            if (ctx.mounted) AppSnackBar.error(ctx, e.toString());
          } catch (_) {
            if (ctx.mounted) AppSnackBar.error(ctx, 'Could not send invite.');
          } finally {
            if (ctx.mounted) setState(() => sending = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Invite a teacher', style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'They get teacher access the moment they sign up or log in '
              'with this email.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'teacher@example.com',
              ),
              onSubmitted: (_) => send(),
            ),
            const SizedBox(height: 14),
            const JzNoteCard(
              body: Text(
                'A teacher can create classes, add students and mark '
                'attendance. They cannot invite other teachers or see '
                'classes that are not theirs.',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: sending ? null : send,
              child: sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send invite'),
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
            AppSnackBar.error(ctx, 'Enter a class name');
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
              AppSnackBar.error(ctx, 'Could not create the class.');
            }
          } finally {
            if (ctx.mounted) setState(() => saving = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New class', style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Students living at the madrasa — all five prayers are marked '
              'for them.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Class name',
                hintText: 'e.g. Batch C',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: section,
              decoration: const InputDecoration(
                labelText: 'Section — optional',
                hintText: 'e.g. Dars-e-Nizami year 1',
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
                  : const Text('Create class'),
            ),
          ],
        );
      },
    ),
  );
}
