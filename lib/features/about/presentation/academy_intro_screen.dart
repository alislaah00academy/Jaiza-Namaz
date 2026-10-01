import 'package:flutter/material.dart';

import '../../../core/widgets/jaiza_scaffold.dart';
import '../../../core/l10n/l10n.dart';

/// Urdu introduction document for Al Islaah Academy (RTL).
class AcademyIntroScreen extends StatelessWidget {
  const AcademyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = _Content(context.l10n);
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              c.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c.introParagraph,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  c.sectionAghaz,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.aghazBody1,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  c.aghazBody2,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  c.aghazBody3,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c.departmentsLead,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  c.educationDeptTitle,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.educationDeptBody,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c.detailedCoursesHeading,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...c.detailedCourses.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• $line',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c.shortCoursesHeading,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  c.shortCourses.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${i + 1}.',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            c.shortCourses[i],
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.closingLine,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Urdu-first content (17 §4): the Academy's text is Urdu in every app
/// language, so both ARB files carry the same Urdu strings.
class _Content {
  const _Content(this.l);
  final L10n l;

  String get title => l.academyIntroTitle;
  String get introParagraph => l.academyIntroIntroParagraph;
  String get sectionAghaz => l.academyIntroSectionAghaz;
  String get aghazBody1 => l.academyIntroAghazBody1;
  String get aghazBody2 => l.academyIntroAghazBody2;
  String get aghazBody3 => l.academyIntroAghazBody3;
  String get departmentsLead => l.academyIntroDepartmentsLead;
  String get educationDeptTitle => l.academyIntroEducationDeptTitle;
  String get educationDeptBody => l.academyIntroEducationDeptBody;
  String get detailedCoursesHeading => l.academyIntroDetailedCoursesHeading;
  String get shortCoursesHeading => l.academyIntroShortCoursesHeading;
  String get closingLine => l.academyIntroClosingLine;
  List<String> get detailedCourses => [l.academyIntroDetailedCourses1, l.academyIntroDetailedCourses2, l.academyIntroDetailedCourses3];
  List<String> get shortCourses => [l.academyIntroShortCourses1, l.academyIntroShortCourses2, l.academyIntroShortCourses3, l.academyIntroShortCourses4, l.academyIntroShortCourses5, l.academyIntroShortCourses6, l.academyIntroShortCourses7, l.academyIntroShortCourses8, l.academyIntroShortCourses9, l.academyIntroShortCourses10, l.academyIntroShortCourses11];
}
