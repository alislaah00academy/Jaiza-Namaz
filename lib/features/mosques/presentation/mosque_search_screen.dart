import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/jz_ui.dart';
import '../data/mosque_data.dart';
import 'mosque_widgets.dart';

/// Search: back arrow + live search field in place of a title.
class MosqueSearchScreen extends ConsumerStatefulWidget {
  const MosqueSearchScreen({super.key});

  @override
  ConsumerState<MosqueSearchScreen> createState() => _MosqueSearchScreenState();
}

class _MosqueSearchScreenState extends ConsumerState<MosqueSearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final results = searchMosques(ref.watch(mosquesProvider), _query.text);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/app/mosques'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: JzSearchBar(
                  controller: _query,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RegisterMosqueAction(),
              const SizedBox(height: 20),
              JzSectionLabel(
                '${results.length} ${results.length == 1 ? 'result' : 'results'}',
              ),
              if (results.isEmpty)
                JzCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No mosque matches “${_query.text.trim()}”. You can '
                    'register it above.',
                    style: t.bodyMedium,
                  ),
                )
              else
                MosqueListCard(mosques: results),
            ],
          ),
        ),
      ],
    );
  }
}
