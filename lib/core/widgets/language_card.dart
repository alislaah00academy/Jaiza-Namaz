import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../l10n/locale_provider.dart';
import 'jz_ui.dart';

/// Language picker card (D-090): Device · English · اردو.
class LanguageCard extends ConsumerWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return JzCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.languageTitle, style: t.titleMedium),
          const SizedBox(height: 2),
          Text(l10n.languageSubtitle, style: t.bodySmall),
          const SizedBox(height: 12),
          JzSegmented<AppLanguage?>(
            options: {
              null: l10n.languageSystem,
              AppLanguage.en: l10n.languageEnglish,
              AppLanguage.ur: l10n.languageUrdu,
            },
            selected: ref.watch(languageChoiceProvider),
            onChanged: (v) => ref.read(languageChoiceProvider.notifier).set(v),
          ),
        ],
      ),
    );
  }
}
