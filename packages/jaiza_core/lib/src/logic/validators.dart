/// Input rules shared by the app and the dashboard.
abstract final class Validators {
  /// Matches the Firebase Auth password policy (15 §4.1): at least 8
  /// characters, with at least one letter and one number.
  static bool isValidPassword(String value) =>
      value.length >= 8 &&
      value.contains(RegExp(r'[A-Za-z]')) &&
      value.contains(RegExp(r'[0-9]'));
}
