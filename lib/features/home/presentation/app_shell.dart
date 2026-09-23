import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_home_route.dart';
import '../../../core/widgets/home_widget_syncer.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/organization.dart';
import '../../../data/models/user_role.dart';
import '../../../providers/providers.dart';
import '../../mosques/data/mosque_data.dart';

/// Shared scaffold for authenticated app section: drawer + dynamic title (phone),
/// or [NavigationRail] + constrained body (wide).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static String titleForPath(String path) {
    if (path.contains('/family/reminders')) return 'Family reminders';
    if (path.contains('/family/qaza/')) return 'Qaza';
    if (path.contains('/family')) return 'Family';
    if (path.contains('/qaza/estimate')) return 'My estimate';
    if (path.contains('/qaza/plan')) return 'Add past Qaza';
    if (path.contains('/qaza/prayer/')) {
      final name = path.split('/').last;
      return name.isEmpty
          ? 'Qaza'
          : 'Qaza ${name[0].toUpperCase()}${name.substring(1)}';
    }
    if (path.contains('/mosques/register')) return 'Register a mosque';
    if (path.startsWith('/app/mosques/')) {
      return mosqueById(path.split('/').last)?.name ?? 'Mosque';
    }
    if (path.contains('/mosques')) return 'Mosques';
    if (path.contains('/history')) return 'Records';
    if (path.contains('/more')) return 'More';
    if (path.contains('/home')) return 'Today';
    if (path.contains('/fard')) return 'Faraiz';
    if (path.contains('/nawafil')) return 'Nawafil';
    if (path.contains('/qaza')) return 'Qaza';
    if (path.contains('/benefits')) return 'Fazail of Prayers';
    if (path.contains('/academy-intro')) return 'Al Islaah Academy';
    if (path.contains('/about')) return 'About Jaiza';
    if (path.contains('/contact')) return 'Contact';
    if (path.contains('/donation')) return 'Donation';
    if (path.contains('/widget-settings')) return 'Notifications & widgets';
    if (path.contains('/profile')) return 'Profile';
    if (path.contains('/change-password')) return 'Change password';
    if (path.contains('/coming-soon')) return AppStrings.comingSoonTitle;
    if (path.contains('/org/admin/teacher/')) return 'Teacher';
    if (path.contains('/org/teacher/class/') && path.contains('/student/')) {
      return 'Student';
    }
    if (path.contains('/org/teacher/class/') &&
        path.contains('/add-students')) {
      return 'Add students';
    }
    if (path.contains('/org/teacher/class/')) return 'Class';
    if (path.contains('/parent')) return 'Children';
    return AppStrings.appName;
  }

  static int? _railIndexForLocation(String location, UserRole? role) {
    // Parent is remapped to individual before reaching here (see build()).
    if (role == UserRole.organization) {
      if (location.contains('/home')) return 0;
      if (location.contains('/org')) return 1;
      if (location.contains('/mosques')) return 2;
      if (location.contains('/history')) return 3;
      if (location.contains('/more')) return 4;
      return null;
    }
    if (location.contains('/home')) return 0;
    if (location.contains('/mosques')) return 1;
    if (location.contains('/history')) return 2;
    if (location.contains('/more')) return 3;
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
    // Parent is remapped to individual before reaching here (see build()).
    if (role == UserRole.organization) {
      switch (index) {
        case 0:
          context.go('/app/home');
          break;
        case 1:
          context.go('/app/org');
          break;
        case 2:
          context.go('/app/mosques');
          break;
        case 3:
          context.go('/app/history');
          break;
        case 4:
          context.go('/app/more');
          break;
      }
      return;
    }
    switch (index) {
      case 0:
        context.go('/app/home');
        break;
      case 1:
        context.go('/app/mosques');
        break;
      case 2:
        context.go('/app/history');
        break;
      case 3:
        context.go('/app/more');
        break;
    }
  }

  static List<NavigationRailDestination> _railDestinationsForRole(
    UserRole? role,
  ) {
    // Parent is remapped to individual before reaching here (see build()).
    if (role == UserRole.organization) {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Today'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Classes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.mosque_outlined),
          selectedIcon: Icon(Icons.mosque),
          label: Text('Mosques'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('Records'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.menu_rounded),
          selectedIcon: Icon(Icons.menu_rounded),
          label: Text('More'),
        ),
      ];
    }
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: Text('Today'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.mosque_outlined),
        selectedIcon: Icon(Icons.mosque),
        label: Text('Mosques'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history),
        label: Text('Records'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.menu_rounded),
        selectedIcon: Icon(Icons.menu_rounded),
        label: Text('More'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    var title = titleForPath(location);
    if (location.startsWith('/app/family/qaza/')) {
      final id = location.split('/').last;
      final kids = ref.watch(childrenStreamProvider).valueOrNull ?? const [];
      for (final k in kids) {
        if (k.id == id) title = '${k.name}’s Qaza';
      }
    }
    if (location.startsWith('/app/org/admin/teacher/')) {
      final uid = location.split('/').last;
      final org = ref.watch(myOrgProvider).valueOrNull;
      final teachers = org == null
          ? const <TeacherMembership>[]
          : ref.watch(allTeachersForOrgProvider(org.id)).valueOrNull ??
                const [];
      for (final tt in teachers) {
        if (tt.uid == uid) title = tt.name;
      }
    }
    if (location.startsWith('/app/org/teacher/class/')) {
      // Reachable only by the owning teacher (router-guarded), so this is
      // always among their own classes.
      final classId = location.split('/')[4];
      final classes =
          ref.watch(classesForTeacherProvider).valueOrNull ?? const [];
      for (final cl in classes) {
        if (cl.id == classId) {
          title = location.endsWith('/report') ? '${cl.name} report' : cl.name;
        }
      }
    }
    // Parents use the same Today · Mosques · Records · More shell as
    // individuals; Today switches between the parent and each child.
    final role = appUser?.role == UserRole.parent
        ? UserRole.individual
        : appUser?.role;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = AppBreakpoints.useNavigationRailForWidth(
          constraints.maxWidth,
        );
        final isIndividual = role == UserRole.individual || role == null;
        // Organizations (admin or teacher) get the same shell plus a fifth
        // "Classes" tab — same note as above ("the same shell").
        final isOrg = role == UserRole.organization;
        if (!useRail && (isIndividual || isOrg)) {
          return _BottomNavScaffold(
            location: location,
            title: title,
            appUser: appUser,
            showClasses: isOrg,
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
                // Individual/org tab roots and the mosque search draw their
                // own headers, same as on phones.
                appBar:
                    (isIndividual || isOrg) &&
                        (_tabRootPaths(isOrg).contains(location) ||
                            _selfHeadedPaths.contains(location))
                    ? null
                    : _buildAppBar(
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

  static const _drawerRootPaths = <String>{'/app/home', '/app/org'};

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
            if (role == UserRole.organization)
              navTile(
                icon: Icons.school_outlined,
                label: 'Classes',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/app/org');
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

/// Root tab paths for the phone/rail shell. Organizations (admin or
/// teacher) get a fifth "Classes" tab inserted after Today; everyone else
/// gets the plain four.
Set<String> _tabRootPaths(bool showClasses) => {
  '/app/home',
  if (showClasses) '/app/org',
  '/app/mosques',
  '/app/history',
  '/app/more',
};

/// Screens that draw their own top bar (search field in place of a title).
const _selfHeadedPaths = <String>{'/app/mosques/search'};

List<(IconData, IconData, String, String)> _tabsFor(bool showClasses) => [
  (Icons.calendar_today_outlined, Icons.calendar_today, 'Today', '/app/home'),
  if (showClasses) (Icons.school_outlined, Icons.school, 'Classes', '/app/org'),
  (Icons.mosque_outlined, Icons.mosque, 'Mosques', '/app/mosques'),
  (Icons.history_outlined, Icons.history, 'Records', '/app/history'),
  (Icons.menu_rounded, Icons.menu_rounded, 'More', '/app/more'),
];

/// Phone layout: the bottom bar from the redesign (Today · Mosques ·
/// Records · More, plus Classes for Organization accounts). The tab roots
/// draw their own titles; every other screen gets a centred back-button
/// AppBar.
class _BottomNavScaffold extends ConsumerWidget {
  const _BottomNavScaffold({
    required this.location,
    required this.title,
    required this.appUser,
    required this.showClasses,
    required this.child,
  });

  final String location;
  final String title;
  final AppUser? appUser;
  final bool showClasses;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final tabs = _tabsFor(showClasses);
    final isRoot = _tabRootPaths(showClasses).contains(location);
    final noAppBar = isRoot || _selfHeadedPaths.contains(location);
    int? selected;
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].$4)) selected = i;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: noAppBar
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
          SafeArea(bottom: false, top: noAppBar, child: child),
        ],
      ),
      bottomNavigationBar: isRoot
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 62,
                  child: Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Expanded(
                          child: _BottomNavIcon(
                            icon: tabs[i].$1,
                            selectedIcon: tabs[i].$2,
                            label: tabs[i].$3,
                            selected: selected == i,
                            onTap: () => context.go(tabs[i].$4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : null,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
