import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Supported UI languages (D-090). Stored as the language code.
enum AppLanguage {
  en,
  ur;

  Locale get locale => Locale(name);
  bool get isRtl => this == ur;

  static AppLanguage? fromCode(String? code) => switch (code) {
    'en' => en,
    'ur' => ur,
    _ => null,
  };

  /// Default when the user hasn't picked one: Urdu if the device is Urdu,
  /// otherwise English (16 §1).
  static AppLanguage fromDevice(Locale device) =>
      device.languageCode == 'ur' ? ur : en;
}

extension L10nContext on BuildContext {
  /// `context.l10n.markAsPrayed` — every user-facing string comes from ARB.
  L10n get l10n => L10n.of(this);
}

/// Strings for code that has no [BuildContext] (notification texts, widget
/// payloads, background isolates). The app keeps [current] in sync with the
/// active language.
abstract final class L10nLookup {
  static AppLanguage language = AppLanguage.en;

  static L10n get current => lookupL10n(language.locale);
}
