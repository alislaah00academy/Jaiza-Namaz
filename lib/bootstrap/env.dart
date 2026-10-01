/// Build-time configuration (`--dart-define`). Nothing here is a secret.
abstract final class Env {
  /// `flutter run --dart-define=USE_EMULATORS=true` → Auth, Firestore,
  /// Functions and Storage talk to the local Emulator Suite (D-004, 15 §15).
  static const bool useEmulators = bool.fromEnvironment('USE_EMULATORS');

  /// Emulator host override, e.g. your Mac's LAN IP when running on a physical
  /// phone. Default: `10.0.2.2` on the Android emulator, `localhost` elsewhere.
  static const String emulatorHost = String.fromEnvironment('EMULATOR_HOST');

  /// reCAPTCHA Enterprise site key for App Check on web (15 §9). When empty,
  /// web release builds run without App Check (fine while it's in monitor mode).
  static const String recaptchaSiteKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
  );

  /// Optional App Check debug token for web debug builds. When empty, the JS
  /// SDK prints a new one to the browser console to register in the console.
  static const String appCheckWebDebugToken = String.fromEnvironment(
    'APP_CHECK_DEBUG_TOKEN',
  );

  /// The named Firestore database in asia-south1 (D-096). The `(default)`
  /// database is in nam5 and is no longer used by the app.
  static const String firestoreDatabaseId = 'jaiza';

  /// Region for Cloud Functions, Storage and Firestore (D-006).
  static const String functionsRegion = 'asia-south1';
}
