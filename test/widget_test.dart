import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jaiza_namaz/core/l10n/app_strings.dart';
import 'package:jaiza_namaz/features/about/presentation/about_screen.dart';
import 'package:jaiza_namaz/features/about/presentation/academy_intro_screen.dart';

void main() {
  testWidgets('About screen shows academy credit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AboutScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.academyCredit), findsOneWidget);
  });

  testWidgets('Academy intro screen shows Urdu title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AcademyIntroScreen(),
        ),
      ),
    );

    expect(find.textContaining('الاصلاح اکیڈمی'), findsWidgets);
  });
}
