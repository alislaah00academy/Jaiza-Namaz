import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/local_prefs.dart';
import 'l10n.dart';

/// The user's language choice; `null` = follow the device (16 §1).
///
/// Device-only for now. When the P1 user model lands, signed-in users read
/// and write `users/{uid}.locale` and guests keep this device value.
class LanguageChoiceNotifier extends Notifier<AppLanguage?> {
  static const key = 'jz_locale_v1';

  @override
  AppLanguage? build() =>
      AppLanguage.fromCode(ref.watch(sharedPrefsProvider).getString(key));

  Future<void> set(AppLanguage? language) async {
    state = language;
    final prefs = ref.read(sharedPrefsProvider);
    if (language == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, language.name);
    }
  }
}

final languageChoiceProvider =
    NotifierProvider<LanguageChoiceNotifier, AppLanguage?>(
      LanguageChoiceNotifier.new,
    );

/// The device locale; overridable in tests.
final deviceLocaleProvider = Provider(
  (ref) => PlatformDispatcher.instance.locale,
);

/// The language the app is shown in right now.
final appLanguageProvider = Provider<AppLanguage>((ref) {
  final language =
      ref.watch(languageChoiceProvider) ??
      AppLanguage.fromDevice(ref.watch(deviceLocaleProvider));
  L10nLookup.language = language;
  return language;
});

/// Sets [L10nLookup] before any UI exists (start-up, background isolates), so
/// notification and widget texts use the saved language.
void initL10nLookup(SharedPreferences prefs) {
  L10nLookup.language =
      AppLanguage.fromCode(prefs.getString(LanguageChoiceNotifier.key)) ??
      AppLanguage.fromDevice(PlatformDispatcher.instance.locale);
}
