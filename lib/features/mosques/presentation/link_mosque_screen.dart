import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/local/local_prefs.dart';
import '../../../core/utils/role_home_route.dart';
import '../../../core/widgets/jaiza_ornaments.dart';
import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../providers/providers.dart';
import '../data/mosque_data.dart';
import 'mosque_widgets.dart';
import '../../../core/l10n/l10n.dart';

/// The skippable step right after email verification: pick a primary
/// mosque so its Jama'at times show on Today.
class LinkMosqueScreen extends ConsumerStatefulWidget {
  const LinkMosqueScreen({super.key});

  @override
  ConsumerState<LinkMosqueScreen> createState() => _LinkMosqueScreenState();
}

class _LinkMosqueScreenState extends ConsumerState<LinkMosqueScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _finish([Mosque? mosque]) async {
    if (mosque != null) {
      await ref.read(primaryMosqueIdProvider.notifier).set(mosque.id);
      await ref
          .read(jamaatAlertMosquesProvider.notifier)
          .toggle(mosque.id, true);
    }
    await ref.read(mosqueSetupSeenProvider.notifier).set(true);
    if (!mounted) return;
    context.go(homeRouteForAppUser(ref.read(appUserStreamProvider).value));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final results = searchMosques(ref.watch(mosquesProvider), _query.text);
    return Scaffold(
      body: JaizaBackground(
        child: SafeArea(
          child: AuthMaxWidth(
            padding: EdgeInsets.zero,
            child: ListView(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(context.l10n.notNow),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.linkYourMosque,
                        style: t.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(context.l10n.linkMosqueBody, style: t.bodyMedium),
                      const SizedBox(height: 20),
                      JzSearchBar(
                        controller: _query,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      if (results.isEmpty)
                        JzCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            context.l10n.noMosqueFoundRegisterLater,
                            style: t.bodyMedium,
                          ),
                        )
                      else
                        MosqueListCard(
                          mosques: results,
                          onTap: _finish,
                          trailingFor: (m) => IconButton(
                            tooltip: context.l10n.setAsMyMosque,
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              color: c.primary,
                            ),
                            onPressed: () => _finish(m),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const JaizaMosqueSkyline(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
