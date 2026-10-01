import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import '../data/family_data.dart';
import '../../../core/l10n/l10n.dart';

/// True when the signed-in account is a Parent.
final isParentProvider = Provider<bool>(
  (ref) => ref.watch(appUserStreamProvider).value?.role == UserRole.parent,
);

String initialOf(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

/// Round letter avatar (`.pav`).
class LetterAvatar extends StatelessWidget {
  const LetterAvatar(
    this.name, {
    super.key,
    this.size = 32,
    this.onPrimary = false,
  });

  final String name;
  final double size;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPrimary
            ? c.onPrimary.withValues(alpha: 0.25)
            : c.secondaryContainer,
      ),
      child: Text(
        initialOf(name),
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: onPrimary ? c.onPrimary : c.secondary,
        ),
      ),
    );
  }
}

/// "Me · Bilal · Ayesha …" switcher. Selection is [selectedChildIdProvider]
/// (null = the parent themself), shared by Today and Records.
class PersonChipRow extends ConsumerWidget {
  const PersonChipRow({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(appUserStreamProvider).value;
    final children = ref.watch(childrenStreamProvider).value ?? const [];
    final selected = ref.watch(selectedChildIdProvider);
    final valid = selected == null || childById(children, selected) != null;
    final current = valid ? selected : null;

    Widget chip({
      required String label,
      required String avatarName,
      required bool on,
      required VoidCallback onTap,
      bool dot = false,
    }) {
      final c = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: Material(
          color: on ? c.primary : c.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: on ? c.primary : c.outline.withValues(alpha: 0.45),
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LetterAvatar(avatarName, size: 28, onPrimary: on),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: on ? c.onPrimary : c.onSurface,
                    ),
                  ),
                  if (dot) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          chip(
            label: context.l10n.me,
            avatarName: me?.name ?? context.l10n.me,
            on: current == null,
            onTap: () => ref.read(selectedChildIdProvider.notifier).state = null,
          ),
          for (final child in children)
            chip(
              label: child.name,
              avatarName: child.name,
              on: current == child.id,
              dot:
                  current != child.id &&
                  ref.watch(childNeedsAttentionProvider(child.id)),
              onTap: () =>
                  ref.read(selectedChildIdProvider.notifier).state = child.id,
            ),
        ],
      ),
    );
  }
}

/// "Add a child" sheet: name, age and gender. The name goes to the children
/// backend; age and gender are kept on the device.
Future<void> showAddChildSheet(BuildContext context) {
  return showJzSheet<void>(context, builder: (_) => const _AddChildSheet());
}

class _AddChildSheet extends ConsumerStatefulWidget {
  const _AddChildSheet();

  @override
  ConsumerState<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends ConsumerState<_AddChildSheet> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'boy';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final parentUid = ref.read(currentUserProvider)?.uid;
    final name = _name.text.trim();
    if (parentUid == null || name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(childrenRepositoryProvider)
          .addChild(parentUid: parentUid, name: name);
      await ref
          .read(childExtrasProvider.notifier)
          .set(id, ChildExtra(age: int.tryParse(_age.text), gender: _gender));
      if (!mounted) return;
      AppSnackBar.success(context, context.l10n.childAdded(name));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.couldNotAddChild);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.addAChild, style: t.headlineSmall),
        const SizedBox(height: 4),
        Text(
          context.l10n.addChildBody,
          style: t.bodyMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: context.l10n.nameLabel),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                controller: _age,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(labelText: context.l10n.ageLabel),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  JzSectionLabel(context.l10n.genderLabel),
                  JzSegmented<String>(
                    options: {
                      'boy': context.l10n.genderBoy,
                      'girl': context.l10n.genderGirl,
                    },
                    selected: _gender,
                    onChanged: (g) => setState(() => _gender = g),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: _saving || _name.text.trim().isEmpty ? null : _add,
          child: Text(context.l10n.actionAdd),
        ),
      ],
    );
  }
}
