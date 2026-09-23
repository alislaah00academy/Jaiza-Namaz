import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';

enum _Mode { one, paste }

/// Add students one by one, or paste a list — one name per line.
class AddStudentsScreen extends ConsumerStatefulWidget {
  const AddStudentsScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends ConsumerState<AddStudentsScreen> {
  _Mode _mode = _Mode.paste;
  final _one = TextEditingController();
  final _paste = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _one.dispose();
    _paste.dispose();
    super.dispose();
  }

  List<String> get _names => _paste.text
      .split('\n')
      .map((n) => n.trim())
      .where((n) => n.isNotEmpty)
      .toList();

  Future<void> _addOne() async {
    final name = _one.text.trim();
    if (name.isEmpty) return;
    await _add([name]);
  }

  Future<void> _addPasted() async {
    if (_names.isEmpty) return;
    await _add(_names);
  }

  Future<void> _add(List<String> names) async {
    final appUser = ref.read(appUserStreamProvider).valueOrNull;
    final orgId = appUser?.orgId;
    final teacherUid = ref.read(currentUserProvider)?.uid;
    if (orgId == null || teacherUid == null) return;
    setState(() => _saving = true);
    try {
      for (final name in names) {
        await ref
            .read(organizationRepositoryProvider)
            .addStudent(
              orgId: orgId,
              classId: widget.classId,
              teacherUid: teacherUid,
              name: name,
            );
      }
      if (mounted) {
        AppSnackBar.success(
          context,
          names.length == 1
              ? '${names.first} added.'
              : '${names.length} students added.',
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not add students.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        JzSegmented<_Mode>(
          options: const {_Mode.one: 'One by one', _Mode.paste: 'Paste a list'},
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: 16),
        if (_mode == _Mode.one) ..._oneByOne(t) else ..._pasteList(t),
      ],
    );
  }

  List<Widget> _oneByOne(TextTheme t) => [
    TextField(
      controller: _one,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _addOne(),
      decoration: const InputDecoration(labelText: "Student's name"),
    ),
    const SizedBox(height: 18),
    FilledButton(
      onPressed: _saving || _one.text.trim().isEmpty ? null : _addOne,
      child: const Text('Add student'),
    ),
  ];

  List<Widget> _pasteList(TextTheme t) => [
    const JzNoteCard(
      body: Text(
        'One name per line. Thirty students take about a minute this way '
        'instead of thirty separate forms.',
      ),
    ),
    const SizedBox(height: 16),
    const JzSectionLabel('Names'),
    TextField(
      controller: _paste,
      maxLines: 10,
      minLines: 8,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        hintText: 'Abdullah Khan\nIbrahim Siddiqui\nYusuf Malik',
        alignLabelWithHint: true,
      ),
    ),
    const SizedBox(height: 14),
    JzCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_names.length} ${_names.length == 1 ? 'name' : 'names'} found',
              style: t.titleSmall,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 18),
    FilledButton(
      onPressed: _saving || _names.isEmpty ? null : _addPasted,
      child: Text('Add ${_names.length} students'),
    ),
  ];
}
