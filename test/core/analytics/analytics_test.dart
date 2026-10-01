import 'package:flutter_test/flutter_test.dart';
import 'package:jaiza_core/jaiza_core.dart';
import 'package:jaiza_namaz/core/analytics/analytics.dart';

class _RecordingBackend implements AnalyticsBackend {
  final events = <(String, Map<String, Object>?)>[];
  final props = <String, String?>{};
  bool? enabled;

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) async =>
      events.add((name, parameters));

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      props[name] = value;

  @override
  Future<void> setCollectionEnabled(bool enabled) async =>
      this.enabled = enabled;
}

void main() {
  late _RecordingBackend backend;
  late Analytics analytics;

  setUp(() {
    backend = _RecordingBackend();
    analytics = Analytics(backend);
  });

  test('prayer_marked uses enum names and derives nothing personal', () async {
    analytics.prayerMarked(
      prayer: PrayerName.asr,
      type: PrayerType.fard,
      status: PrayerStatus.completed,
      subject: AnalyticsSubject.child,
      source: PrayerLogSource.guardian,
    );
    await pumpEventQueue();
    final (name, params) = backend.events.single;
    expect(name, 'prayer_marked');
    expect(params, {
      'prayer': 'asr',
      'type': 'fard',
      'status': 'completed',
      'subject': 'child',
      'source': 'guardian',
    });
  });

  test('auth and mode events', () async {
    analytics
      ..signUp('password')
      ..login('google')
      ..modeSwitched(AppMode.masjidAdmin);
    await pumpEventQueue();
    expect(backend.events.map((e) => e.$1), [
      'sign_up',
      'login',
      'mode_switched',
    ]);
    expect(backend.events.last.$2, {'mode': 'masjidAdmin'});
  });

  test('class_marked buckets the student count', () async {
    analytics
      ..classMarked(students: 7)
      ..classMarked(students: 30)
      ..classMarked(students: 31);
    await pumpEventQueue();
    expect(backend.events.map((e) => e.$2!['students']), [
      '1-10',
      '11-30',
      '31+',
    ]);
  });

  test('booleans are sent as numbers (Analytics has no bool type)', () async {
    analytics.jamaatPublished(scheduled: true, prayersChanged: 2);
    await pumpEventQueue();
    expect(backend.events.single.$2, {'scheduled': 1, 'prayers_changed': 2});
  });

  test('user properties', () async {
    analytics.setUserProperties(
      activeMode: AppMode.parent,
      modesCount: 2,
      appLanguage: 'ur',
      hasPrimaryMosque: false,
    );
    await pumpEventQueue();
    expect(backend.props, {
      'active_mode': 'parent',
      'modes_count': '2',
      'app_language': 'ur',
      'has_primary_mosque': 'false',
    });
  });

  test('a failing backend never throws into the app', () async {
    final failing = Analytics(_ThrowingBackend());
    failing.login('password');
    await pumpEventQueue();
  });
}

class _ThrowingBackend extends _RecordingBackend {
  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) =>
      Future.error(StateError('offline'));
}
