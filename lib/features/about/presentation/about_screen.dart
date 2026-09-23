import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/jz_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Center(child: JzEmblem(icon: Icons.mosque_outlined)),
        const SizedBox(height: 18),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: t.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.academyCredit,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(color: c.primary),
        ),
        const SizedBox(height: 22),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Jaiza helps Muslims track obligatory prayers, optional nawafil, '
            'and qaza with gentle motivation — clear progress, no clutter.',
            style: t.bodyLarge,
          ),
        ),
        const SizedBox(height: 14),
        JzCard(
          child: Column(
            children: [
              JzListRow(
                leading: Icon(Icons.menu_book_outlined, color: c.primary),
                title: 'الاصلاح اکیڈمی کا مختصر تعارف',
                subtitle: 'Brief introduction (Urdu)',
                trailing: const JzChevron(),
                showDivider: true,
                onTap: () => context.push('/app/academy-intro'),
              ),
              JzListRow(
                leading: Icon(Icons.school_outlined, color: c.primary),
                title: 'Al Islaah Academy',
                subtitle: 'Courses and admissions',
                trailing: const JzChevron(),
                showDivider: true,
                onTap: () => context.push('/app/academy-intro'),
              ),
              JzListRow(
                leading: Icon(Icons.mail_outline_rounded, color: c.primary),
                title: 'Contact',
                subtitle: 'Reach Al Islaah Academy',
                trailing: const JzChevron(),
                onTap: () => context.push('/app/contact'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
