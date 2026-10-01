import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaiza_core/jaiza_core.dart';

import '../local/local_prefs.dart';
import '../logging/app_log.dart';

/// Where events go. The real one is Firebase Analytics; tests record calls.
abstract interface class AnalyticsBackend {
  Future<void> logEvent(String name, Map<String, Object>? parameters);
  Future<void> setUserProperty(String name, String? value);
  Future<void> setCollectionEnabled(bool enabled);
}

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalyticsBackend(this._fa);
  final FirebaseAnalytics _fa;

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) =>
      _fa.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _fa.setUserProperty(name: name, value: value);

  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _fa.setAnalyticsCollectionEnabled(enabled);
}

/// Who a prayer mark is for (`prayer_marked.subject`).
enum AnalyticsSubject { self, child, student }

/// The typed event list from 17 §6 (D-074). **No personal data** in
/// parameters: no names, emails, phones, CNIC or exact locations. Only add
/// events here, never call Firebase Analytics directly.
class Analytics {
  Analytics(this._backend);
  final AnalyticsBackend _backend;

  // Auth & modes --------------------------------------------------------------

  /// `method`: password / google / apple / phone.
  void signUp(String method) => _log('sign_up', {'method': method});
  void login(String method) => _log('login', {'method': method});
  void modeChosen(AppMode mode) => _log('mode_chosen', {'mode': mode.name});
  void modeSwitched(AppMode mode) => _log('mode_switched', {'mode': mode.name});

  // Prayers -------------------------------------------------------------------

  void prayerMarked({
    required PrayerName prayer,
    required PrayerType type,
    required PrayerStatus? status,
    required AnalyticsSubject subject,
    PrayerLogSource source = PrayerLogSource.app,
  }) => _log('prayer_marked', {
    'prayer': prayer.name,
    'type': type.name,
    'status': status?.name ?? 'cleared',
    'subject': subject.name,
    'source': source.name,
  });

  void qazaLogged({required PrayerName prayer, required int delta}) =>
      _log('qaza_logged', {'prayer': prayer.name, 'delta': delta});

  // Mosques -------------------------------------------------------------------

  void mosqueSaved({required String city}) =>
      _log('mosque_saved', {'city': city});
  void mosquePrimarySet({required String city}) =>
      _log('mosque_primary_set', {'city': city});

  /// `kind`: nearby / name / city.
  void mosqueSearch({required String kind, required int results}) =>
      _log('mosque_search', {'kind': kind, 'results': results});
  void mosqueRequestSubmitted({required String kind}) =>
      _log('mosque_request_submitted', {'kind': kind});
  void jamaatPublished({
    required bool scheduled,
    required int prayersChanged,
  }) => _log('jamaat_published', {
    'scheduled': scheduled ? 1 : 0,
    'prayers_changed': prayersChanged,
  });
  void reportSubmitted() => _log('report_submitted');

  // Family & organization -----------------------------------------------------

  void childAdded() => _log('child_added');
  void guardianJoined() => _log('guardian_joined');
  void studentLinked() => _log('student_linked');
  void orgCreated() => _log('org_created');
  void teacherInvited() => _log('teacher_invited');
  void classMarked({required int students}) =>
      _log('class_marked', {'students': studentsBucket(students)});

  /// `kind`: class / student. `period`: week / month.
  void reportCardGenerated({required String kind, required String period}) =>
      _log('report_card_generated', {'kind': kind, 'period': period});

  // Other ---------------------------------------------------------------------

  /// Which locked features make guests sign up.
  void guestLockedFeatureTap(String feature) =>
      _log('guest_locked_feature_tap', {'feature': feature});
  void notificationOpened(String type) =>
      _log('notification_opened', {'type': type});

  // User properties -----------------------------------------------------------

  void setUserProperties({
    AppMode? activeMode,
    int? modesCount,
    String? appLanguage,
    bool? hasPrimaryMosque,
  }) {
    if (activeMode != null) _prop('active_mode', activeMode.name);
    if (modesCount != null) _prop('modes_count', '$modesCount');
    if (appLanguage != null) _prop('app_language', appLanguage);
    if (hasPrimaryMosque != null) {
      _prop('has_primary_mosque', '$hasPrimaryMosque');
    }
  }

  /// Profile → Privacy switch (15 §14). Stored on the device.
  Future<void> setCollectionEnabled(bool enabled) =>
      _backend.setCollectionEnabled(enabled);

  /// `class_marked.students` buckets: 1–10, 11–30, 31+.
  static String studentsBucket(int n) => n <= 10
      ? '1-10'
      : n <= 30
      ? '11-30'
      : '31+';

  void _log(String name, [Map<String, Object>? parameters]) {
    unawaited(
      _backend.logEvent(name, parameters).catchError((Object e, StackTrace st) {
        appLog('analytics $name failed', error: e, stackTrace: st);
      }),
    );
  }

  void _prop(String name, String value) {
    unawaited(
      _backend.setUserProperty(name, value).catchError((Object e) {
        appLog('analytics property $name failed', error: e);
      }),
    );
  }
}

final analyticsProvider = Provider<Analytics>(
  (ref) => Analytics(FirebaseAnalyticsBackend(FirebaseAnalytics.instance)),
);

/// Analytics opt-out, on by default (15 §14). Device-only (17 §8).
class AnalyticsEnabledNotifier extends Notifier<bool> {
  static const key = 'jz_analytics_enabled_v1';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(key) ?? true;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref.read(sharedPrefsProvider).setBool(key, enabled);
    await ref.read(analyticsProvider).setCollectionEnabled(enabled);
  }
}

final analyticsEnabledProvider =
    NotifierProvider<AnalyticsEnabledNotifier, bool>(
      AnalyticsEnabledNotifier.new,
    );
