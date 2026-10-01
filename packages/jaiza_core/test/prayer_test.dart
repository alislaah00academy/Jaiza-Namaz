import 'package:jaiza_core/jaiza_core.dart';
import 'package:test/test.dart';

void main() {
  test('prayerLogId is {dateKey}_{prayer}_{type} (06 §2.2)', () {
    expect(
      prayerLogId('2026-09-28', PrayerName.asr, PrayerType.fard),
      '2026-09-28_asr_fard',
    );
    expect(
      prayerLogId('2026-09-28', PrayerName.fajr, PrayerType.qaza),
      '2026-09-28_fajr_qaza',
    );
  });

  test('stored enum names never change (03 §4)', () {
    expect(PrayerName.values.map((e) => e.name), [
      'fajr',
      'zuhr',
      'asr',
      'maghrib',
      'isha',
      'witr',
      'tahajjud',
      'ishraq',
      'chasht',
      'awwabin',
      'rawatib',
      'taraweeh',
      'qazaGeneric',
    ]);
    expect(PrayerType.values.map((e) => e.name), ['fard', 'nawafil', 'qaza']);
    expect(PrayerStatus.values.map((e) => e.name), ['completed', 'missed']);
    expect(AppMode.values.map((e) => e.name), [
      'individual',
      'parent',
      'organization',
      'masjidAdmin',
    ]);
  });

  test('fard list and isFard', () {
    expect(PrayerName.fard, hasLength(5));
    expect(PrayerName.asr.isFard, isTrue);
    expect(PrayerName.witr.isFard, isFalse);
  });

  group('SubjectRef', () {
    test('paths per subject kind', () {
      expect(const SubjectRef.self('u1').prayersPath, 'users/u1/prayers');
      expect(const SubjectRef.child('c1').prayersPath, 'children/c1/prayers');
      expect(
        const SubjectRef.student('s1').dailySummariesPath,
        'students/s1/dailySummaries',
      );
    });

    test('value equality (freezed)', () {
      expect(const SubjectRef.child('c1'), const SubjectRef.child('c1'));
      expect(
        const SubjectRef.child('c1'),
        isNot(const SubjectRef.student('c1')),
      );
    });

    test('JSON round-trip with a kind key', () {
      const ref = SubjectRef.student('s9');
      final json = ref.toJson();
      expect(json, {'kind': 'student', 'studentId': 's9'});
      expect(SubjectRef.fromJson(json), ref);
    });
  });
}
