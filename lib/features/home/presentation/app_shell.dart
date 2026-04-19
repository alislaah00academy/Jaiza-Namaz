import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../providers/providers.dart';

/// Shared scaffold for authenticated app section: drawer + dynamic title.
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static String titleForPath(String path) {
    if (path.contains('/home')) return 'Home';
    if (path.contains('/fard')) return 'Faraiz';
    if (path.contains('/nawafil')) return 'Nawafil';
    if (path.contains('/qaza')) return 'Qaza';
    if (path.contains('/benefits')) return 'Benefits of Prayer';
    if (path.contains('/about')) return 'About Us';
    if (path.contains('/contact')) return 'Contact';
    if (path.contains('/donation')) return 'Donation';
    if (path.contains('/profile')) return 'Profile';
    if (path.contains('/change-password')) return 'Change password';
    if (path.contains('/coming-soon')) return AppStrings.comingSoonTitle;
    return AppStrings.appName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = titleForPath(location);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) {
            if (location.contains('/home')) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              );
            }
            return IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/app/home');
                }
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      AppStrings.academyCredit,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: const Text('Change password'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/change-password');
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/welcome');
                },
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
