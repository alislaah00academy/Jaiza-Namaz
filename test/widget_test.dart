import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaiza_namaz/features/about/presentation/about_screen.dart';
import 'package:jaiza_namaz/features/about/presentation/academy_intro_screen.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('About screen shows academy credit', (tester) async {
    final l10n = await pumpLocalized(tester, const AboutScreen());
    expect(find.text(l10n.academyCredit), findsOneWidget);
  });

  testWidgets('About screen in Urdu is right-to-left', (tester) async {
    final l10n = await pumpLocalized(
      tester,
      const AboutScreen(),
      locale: const Locale('ur'),
    );
    expect(find.text(l10n.academyCredit), findsOneWidget);
    final dir = Directionality.of(tester.element(find.byType(AboutScreen)));
    expect(dir, TextDirection.rtl);
  });

  testWidgets('Academy intro screen shows Urdu title', (tester) async {
    await pumpLocalized(tester, const AcademyIntroScreen());
    expect(find.textContaining('الاصلاح اکیڈمی'), findsWidgets);
  });
}
