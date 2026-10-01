import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../core/l10n/l10n.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.contactTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.contactIntro,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        JaizaSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(context.l10n.academyName),
                subtitle: Text(context.l10n.academyCredit),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push('/app/academy-intro'),
                  child: Text(context.l10n.contactBriefIntro),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JaizaSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(context.l10n.emailLabel),
            subtitle: Text(context.l10n.contactEmailPlaceholder),
          ),
        ),
      ],
    );
  }
}
