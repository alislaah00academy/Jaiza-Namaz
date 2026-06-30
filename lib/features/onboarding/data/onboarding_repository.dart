import 'package:shared_preferences/shared_preferences.dart';

/// Persists the "user has seen onboarding" flag locally (per install) so the
/// three onboarding screens only show on first launch. Simple bool in
/// SharedPreferences — survives restarts, cleared on uninstall.
class OnboardingRepository {
  OnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'jaiza_onboarding_complete_v1';

  bool get isComplete => _prefs.getBool(_key) ?? false;

  Future<void> markComplete() => _prefs.setBool(_key, true);
}
