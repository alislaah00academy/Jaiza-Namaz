import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaiza_namaz/core/firestore/converters.dart';

void main() {
  group('FirestoreJson.decode', () {
    test('turns Timestamps and GeoPoints into JSON values at any depth', () {
      final ts = Timestamp.fromDate(DateTime.utc(2026, 9, 28, 4, 45));
      final decoded = FirestoreJson.decode({
        'name': 'Masjid',
        'createdAt': ts,
        'location': const GeoPoint(24.86, 67.0),
        'nested': {
          'at': ts,
          'list': [ts, 1],
        },
      });

      expect(decoded['name'], 'Masjid');
      expect(decoded['createdAt'], '2026-09-28T04:45:00.000Z');
      expect(decoded['location'], {'lat': 24.86, 'lng': 67.0});
      expect((decoded['nested'] as Map)['at'], '2026-09-28T04:45:00.000Z');
      expect((decoded['nested'] as Map)['list'], [
        '2026-09-28T04:45:00.000Z',
        1,
      ]);
    });
  });

  group('FirestoreJson.encode', () {
    test('server owns createdAt/updatedAt by default', () {
      final out = FirestoreJson.encode({'name': 'x', 'createdAt': 'old'});
      expect(out['createdAt'], isA<FieldValue>());
      expect(out['updatedAt'], isA<FieldValue>());
    });

    test('keeps fields as-is when serverTimestamps is off', () {
      final out = FirestoreJson.encode({'a': 1}, serverTimestamps: false);
      expect(out, {'a': 1});
    });

    test('converts listed date and geo fields', () {
      final out = FirestoreJson.encode(
        {
          'birthAt': '2026-09-28T04:45:00.000Z',
          'loc': {'lat': 1, 'lng': 2.5},
          'note': '2026-09-28T04:45:00.000Z',
        },
        dateFields: {'birthAt'},
        geoFields: {'loc'},
        serverTimestamps: false,
      );
      expect(
        out['birthAt'],
        Timestamp.fromDate(DateTime.utc(2026, 9, 28, 4, 45)),
      );
      expect(out['loc'], const GeoPoint(1, 2.5));
      expect(out['note'], '2026-09-28T04:45:00.000Z');
    });
  });

  test('TimestampConverter round-trips', () {
    const c = TimestampConverter();
    final d = DateTime.utc(2026, 1, 2, 3, 4);
    expect(c.fromJson(c.toJson(d))!.toUtc(), d);
    expect(c.fromJson('2026-01-02T03:04:00.000Z'), d);
    expect(c.fromJson(null), isNull);
  });

  test('GeoPointConverter round-trips', () {
    const c = GeoPointConverter();
    const p = GeoPoint(24.86, 67.0);
    expect(c.fromJson(c.toJson(p)), p);
  });
}
