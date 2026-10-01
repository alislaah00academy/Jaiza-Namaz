import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
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
          context.l10n.appName,
          textAlign: TextAlign.center,
          style: t.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.academyCredit,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(color: c.primary),
        ),
        const SizedBox(height: 22),
        JzCard(
          padding: const EdgeInsets.all(18),
          child: Text(context.l10n.aboutBody, style: t.bodyLarge),
        ),
        const SizedBox(height: 14),
        JzCard(
          child: Column(
            children: [
              JzListRow(
                leading: Icon(Icons.menu_book_outlined, color: c.primary),
                title: context.l10n.academyIntroTitle,
                subtitle: context.l10n.aboutAcademyIntroSubtitle,
                trailing: const JzChevron(),
                showDivider: true,
                onTap: () => context.push('/app/academy-intro'),
              ),
              JzListRow(
                leading: Icon(Icons.school_outlined, color: c.primary),
                title: context.l10n.academyName,
                subtitle: context.l10n.aboutCoursesSubtitle,
                trailing: const JzChevron(),
                showDivider: true,
                onTap: () => context.push('/app/academy-intro'),
              ),
              JzListRow(
                leading: Icon(Icons.mail_outline_rounded, color: c.primary),
                title: context.l10n.contactTitle,
                subtitle: context.l10n.aboutContactSubtitle,
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
