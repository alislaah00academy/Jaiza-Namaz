/// The modes one account can hold at the same time (D-010, 05 §4).
///
/// Stored as `name` in `users/{uid}.lastMode` and in device prefs.
enum AppMode { individual, parent, organization, masjidAdmin }
