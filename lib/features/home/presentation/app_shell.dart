import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_home_route.dart';
import '../../../core/widgets/home_widget_syncer.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import 'quick_mark_sheet.dart';

/// Shared scaffold for authenticated app section: drawer + dynamic title (phone),
/// or [NavigationRail] + constrained body (wide).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static String titleForPath(String path) {
    if (path.contains('/home')) return 'Home';
    if (path.contains('/fard')) return 'Faraiz';
    if (path.contains('/nawafil')) return 'Nawafil';
    if (path.contains('/qaza')) return 'Qaza';
    if (path.contains('/benefits')) return 'Fazail of Prayers';
    if (path.contains('/academy-intro')) return 'Al Islaah Academy';
    if (path.contains('/about')) return 'About Us';
    if (path.contains('/contact')) return 'Contact';
    if (path.contains('/donation')) return 'Donation';
    if (path.contains('/widget-settings')) return 'Widgets & Notifications';
    if (path.contains('/profile')) return 'Profile';
    if (path.contains('/change-password')) return 'Change password';
    if (path.contains('/coming-soon')) return AppStrings.comingSoonTitle;
    if (path.contains('/org/admin')) return 'Organization';
    if (path.contains('/org/teacher')) return 'My Classes';
    if (path.contains('/parent')) return 'Children';
    return AppStrings.appName;
  }

  static int? _railIndexForLocation(String location, UserRole? role) {
    if (role == UserRole.parent) {
      if (location.contains('/parent')) return 0;
      if (location.contains('/profile')) return 1;
      if (location.contains('/change-password')) return 2;
      return null;
    }
    if (role == UserRole.organization) {
      if (location.contains('/org')) return 0;
      if (location.contains('/profile')) return 1;
      if (location.contains('/change-password')) return 2;
      return null;
    }
    if (location.contains('/home')) return 0;
    if (location.contains('/profile')) return 1;
    if (location.contains('/change-password')) return 2;
    return null;
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go('/welcome');
  }

  static void _onRailDestinationSelected(
    BuildContext context,
    UserRole? role,
    int index,
  ) {
    if (role == UserRole.parent) {
      switch (index) {
        case 0:
          context.go('/app/parent');
          break;
        case 1:
          context.go('/app/profile');
          break;
        case 2:
          context.go('/app/change-password');
          break;
      }
      return;
    }
    if (role == UserRole.organization) {
      switch (index) {
        case 0:
          context.go('/app/org/admin');
          break;
        case 1:
          context.go('/app/profile');
          break;
        case 2:
          context.go('/app/change-password');
          break;
      }
      return;
    }
    switch (index) {
      case 0:
        context.go('/app/home');
        break;
      case 1:
        context.go('/app/profile');
        break;
      case 2:
        context.go('/app/change-password');
        break;
    }
  }

  static List<NavigationRailDestination> _railDestinationsForRole(
    UserRole? role,
  ) {
    if (role == UserRole.parent) {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom),
          label: Text('Children'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.lock_reset_outlined),
          selectedIcon: Icon(Icons.lock_reset),
          label: Text('Change password'),
        ),
      ];
    }
    if (role == UserRole.organization) {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Organization'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.lock_reset_outlined),
          selectedIcon: Icon(Icons.lock_reset),
          label: Text('Change password'),
        ),
      ];
    }
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.lock_reset_outlined),
        selectedIcon: Icon(Icons.lock_reset),
        label: Text('Change password'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = titleForPath(location);
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final role = appUser?.role;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = AppBreakpoints.useNavigationRailForWidth(
          constraints.maxWidth,
        );
        final isIndividual = role == UserRole.individual || role == null;
        if (!useRail && isIndividual) {
          return _IndividualBottomNavScaffold(
            location: location,
            title: title,
            appUser: appUser,
            child: child,
          );
        }
        if (!useRail) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(
              context,
              title: title,
              useRail: false,
              appUser: appUser,
            ),
            drawer: _buildDrawer(context, ref, role),
            body: Stack(
              fit: StackFit.expand,
              children: [const HomeWidgetSyncer(), child],
            ),
          );
        }

        final railIndex = _railIndexForLocation(location, role);
        final scheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            NavigationRail(
              backgroundColor: scheme.surfaceContainerLow,
              selectedIndex: railIndex,
              onDestinationSelected: (index) =>
                  _onRailDestinationSelected(context, role, index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  Icons.mosque_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IconButton(
                      tooltip: 'Sign out',
                      icon: const Icon(Icons.logout),
                      onPressed: () => _signOut(context, ref),
                    ),
                  ),
                ),
              ),
              destinations: _railDestinationsForRole(role),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: _buildAppBar(
                  context,
                  title: title,
                  useRail: true,
                  appUser: appUser,
                ),
                body: MaxWidthBody(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [const HomeWidgetSyncer(), child],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static const _drawerRootPaths = <String>{
    '/app/home',
    '/app/parent',
    '/app/org/admin',
    '/app/org/teacher',
  };

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required String title,
    required bool useRail,
    required AppUser? appUser,
  }) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: _buildLeading(context, useRail: useRail, appUser: appUser),
    );
  }

  Widget? _buildLeading(
    BuildContext context, {
    required bool useRail,
    required AppUser? appUser,
  }) {
    if (location.contains('/home') || _drawerRootPaths.contains(location)) {
      if (useRail) return null;
      return Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(homeRouteForAppUser(appUser));
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, UserRole? role) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget navTile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: scheme.surfaceContainerLow,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
            side: BorderSide(color: scheme.outline.withValues(alpha: 0.15)),
          ),
          child: ListTile(
            leading: Icon(icon, color: scheme.primary),
            title: Text(label, style: textTheme.titleSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusButton),
            ),
            onTap: onTap,
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.secondaryContainer,
                    scheme.surfaceContainerHigh,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTokens.radiusCard),
                  bottomRight: Radius.circular(AppTokens.radiusCard),
                ),
                boxShadow: AppTokens.softShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.mosque_rounded, size: 40, color: scheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.appName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.academyCredit,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (role == UserRole.parent)
              navTile(
                icon: Icons.family_restroom_outlined,
                label: 'Children',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/parent');
                },
              )
            else if (role == UserRole.organization)
              navTile(
                icon: Icons.school_outlined,
                label: 'Organization',
                onTap: () {
                  Navigator.pop(context);
                  context.go(
                    ref
                                .read(appUserStreamProvider)
                                .valueOrNull
                                ?.orgMemberRole ==
                            OrgMemberRole.teacher
                        ? '/app/org/teacher'
                        : '/app/org/admin',
                  );
                },
              )
            else ...[
              navTile(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/home');
                },
              ),
              navTile(
                icon: Icons.widgets_outlined,
                label: 'Widgets & Notifications',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/widget-settings');
                },
              ),
            ],
            navTile(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                context.go('/app/profile');
              },
            ),
            navTile(
              icon: Icons.lock_reset_outlined,
              label: 'Change password',
              onTap: () {
                Navigator.pop(context);
                context.go('/app/change-password');
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(color: scheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Material(
                color: scheme.errorContainer.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                ),
                child: ListTile(
                  leading: Icon(Icons.logout, color: scheme.error),
                  title: Text(
                    'Sign out',
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _signOut(context, ref);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual phone layout: bottom nav (Home/History/quick-mark/Reminders/
/// Profile) instead of the drawer+AppBar pattern used by Parent/Org and
/// wide screens. Other Individual screens reached via the home grid (Fard,
/// Nawafil, Qaza, Fazail, About, Contact, Donation, Widgets & Notifications,
/// Change password) still get a plain back-button AppBar — only the four
/// nav-root tabs are immersive (no AppBar), matching the reference design.
class _IndividualBottomNavScaffold extends ConsumerWidget {
  const _IndividualBottomNavScaffold({
    required this.location,
    required this.title,
    required this.appUser,
    required this.child,
  });

  final String location;
  final String title;
  final AppUser? appUser;
  final Widget child;

  static const _rootPaths = <String>{
    '/app/home',
    '/app/history',
    '/app/reminders',
    '/app/profile',
  };

  int? get _selectedIndex {
    if (location.contains('/home')) return 0;
    if (location.contains('/history')) return 1;
    if (location.contains('/reminders')) return 3;
    if (location.contains('/profile')) return 4;
    return null;
  }

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    switch (index) {
      case 0:
        context.go('/app/home');
        break;
      case 1:
        context.go('/app/history');
        break;
      case 2:
        showQuickMarkSheet(context, ref);
        break;
      case 3:
        context.go('/app/reminders');
        break;
      case 4:
        context.go('/app/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isRoot = _rootPaths.contains(location);
    final selected = _selectedIndex;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isRoot
          ? null
          : AppBar(
              title: Text(title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(homeRouteForAppUser(appUser));
                  }
                },
              ),
            ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HomeWidgetSyncer(),
          SafeArea(bottom: false, child: child),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickMarkSheet(context, ref),
        shape: const CircleBorder(),
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        child: const Icon(Icons.menu_book_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavIcon(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              selected: selected == 0,
              onTap: () => _onTap(context, ref, 0),
            ),
            _BottomNavIcon(
              icon: Icons.history_outlined,
              selectedIcon: Icons.history,
              label: 'History',
              selected: selected == 1,
              onTap: () => _onTap(context, ref, 1),
            ),
            const SizedBox(width: 48),
            _BottomNavIcon(
              icon: Icons.notifications_outlined,
              selectedIcon: Icons.notifications,
              label: 'Reminders',
              selected: selected == 3,
              onTap: () => _onTap(context, ref, 3),
            ),
            _BottomNavIcon(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              selected: selected == 4,
              onTap: () => _onTap(context, ref, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
