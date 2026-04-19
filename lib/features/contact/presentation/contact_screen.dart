import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Contact',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Reach out to Al Islaah Academy for questions about the app, '
          'classes, or general support.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Al Islaah Academy'),
            subtitle: Text(AppStrings.academyCredit),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email'),
            subtitle: Text('Add your official contact email in the console'),
          ),
        ),
      ],
    );
  }
}
