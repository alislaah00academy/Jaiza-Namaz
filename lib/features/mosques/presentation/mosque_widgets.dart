import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/local/local_prefs.dart';
import '../../../core/widgets/jz_ui.dart';
import '../data/mosque_data.dart';

/// `.mrow` for a mosque: avatar, name, area · distance, and a star that
/// saves/unsaves it (or [trailing] to replace the star).
class MosqueRow extends ConsumerWidget {
  const MosqueRow({
    super.key,
    required this.mosque,
    this.showDivider = false,
    this.onTap,
    this.trailing,
  });

  final Mosque mosque;
  final bool showDivider;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).colorScheme;
    final saved = ref.watch(savedMosqueIdsProvider).contains(mosque.id);
    final isPrimary = ref.watch(primaryMosqueIdProvider) == mosque.id;
    return JzListRow(
      leading: const JzAvatar(
        icon: Icons.mosque_outlined,
        size: 40,
        iconSize: 20,
      ),
      title: mosque.name,
      subtitle: mosque.subtitle,
      showDivider: showDivider,
      onTap: onTap ?? () => context.push('/app/mosques/${mosque.id}'),
      trailing:
          trailing ??
          (isPrimary
              ? Icon(Icons.check_circle_rounded, color: c.tertiary)
              : IconButton(
                  tooltip: saved ? 'Remove from saved' : 'Save',
                  icon: Icon(
                    saved ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: saved ? c.tertiary : c.onSurfaceVariant,
                  ),
                  onPressed: () => ref
                      .read(savedMosqueIdsProvider.notifier)
                      .toggle(mosque.id),
                )),
    );
  }
}

/// A card holding a list of [MosqueRow]s with hairlines between them.
class MosqueListCard extends StatelessWidget {
  const MosqueListCard({
    super.key,
    required this.mosques,
    this.onTap,
    this.trailingFor,
  });

  final List<Mosque> mosques;
  final void Function(Mosque)? onTap;
  final Widget Function(Mosque)? trailingFor;

  @override
  Widget build(BuildContext context) {
    return JzCard(
      child: Column(
        children: [
          for (var i = 0; i < mosques.length; i++)
            MosqueRow(
              mosque: mosques[i],
              showDivider: i < mosques.length - 1,
              onTap: onTap == null ? null : () => onTap!(mosques[i]),
              trailing: trailingFor?.call(mosques[i]),
            ),
        ],
      ),
    );
  }
}

/// "Register a new mosque — If yours isn't listed yet".
class RegisterMosqueAction extends StatelessWidget {
  const RegisterMosqueAction({super.key});

  @override
  Widget build(BuildContext context) => JzDashedAction(
    icon: Icons.add_location_alt_outlined,
    title: 'Register a new mosque',
    subtitle: "If yours isn't listed yet",
    onTap: () => context.push('/app/mosques/register'),
  );
}
