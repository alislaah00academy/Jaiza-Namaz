import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every English string has an Urdu translation with the same placeholders
/// (16 §1.1). Runs on the source ARB files, so a missing key fails CI even
/// before gen-l10n would fall back to English at runtime.
void main() {
  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('lib/core/l10n/arb/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

  final en = load('en');
  final ur = load('ur');
  final keys = en.keys.where((k) => !k.startsWith('@')).toList();

  Set<String> placeholders(String s) =>
      RegExp(r'\{(\w+)[},]').allMatches(s).map((m) => m.group(1)!).toSet();

  test('Urdu has every English key', () {
    final missing = keys.where((k) => !ur.containsKey(k)).toList();
    expect(missing, isEmpty, reason: 'Missing in app_ur.arb: $missing');
  });

  test('no stray Urdu keys', () {
    final extra = ur.keys
        .where((k) => !k.startsWith('@') && !en.containsKey(k))
        .toList();
    expect(extra, isEmpty, reason: 'Not in app_en.arb: $extra');
  });

  test('placeholders match between English and Urdu', () {
    for (final k in keys) {
      final declared =
          ((en['@$k'] as Map?)?['placeholders'] as Map?)?.keys.toSet() ??
          <String>{};
      // Urdu must use every declared placeholder (plural branches may drop
      // the plain `{count}` but always keep the ICU variable).
      for (final p in declared) {
        expect(
          placeholders(ur[k] as String).contains(p),
          isTrue,
          reason: '$k: Urdu text is missing {$p}',
        );
      }
    }
  });

  test('no empty translations', () {
    for (final k in keys) {
      expect((ur[k] as String).trim(), isNotEmpty, reason: k);
    }
  });
}
