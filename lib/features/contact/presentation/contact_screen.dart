import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/jaiza_scaffold.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Contact',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Reach out to Al Islaah Academy for questions about the app, '
          'classes, or general support.',
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
                title: const Text('Al Islaah Academy'),
                subtitle: Text(AppStrings.academyCredit),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push('/app/academy-intro'),
                  child: const Text('مختصر تعارف · Brief intro'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JaizaSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email'),
            subtitle: Text('Add your official contact email in the console'),
          ),
        ),
      ],
    );
  }
}
