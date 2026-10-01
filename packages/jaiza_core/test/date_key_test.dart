import 'package:jaiza_core/jaiza_core.dart';
import 'package:test/test.dart';

void main() {
  group('DateKeys.of / monthOf', () {
    test('pads year, month and day', () {
      expect(DateKeys.of(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
      expect(DateKeys.monthOf(DateTime(2026, 3, 7)), '2026-03');
    });

    test('uses the local calendar of a UTC instant', () {
      final utc = DateTime.utc(2026, 9, 28, 12);
      expect(DateKeys.of(utc), DateKeys.of(utc.toLocal()));
    });
  });

  group('DateKeys.parse / isValid', () {
    test('round-trips', () {
      expect(DateKeys.parse('2026-09-28'), DateTime(2026, 9, 28));
      expect(DateKeys.of(DateKeys.parse('2024-02-29')), '2024-02-29');
    });

    test('rejects malformed and impossible dates', () {
      for (final bad in ['2026-9-28', '2026-02-30', '2025-02-29', '', 'x']) {
        expect(DateKeys.isValid(bad), isFalse, reason: bad);
        expect(() => DateKeys.parse(bad), throwsFormatException);
      }
    });
  });

  group('DateKeys.addDays / daysBetween', () {
    test('crosses month, year and leap day', () {
      expect(DateKeys.addDays('2026-01-31', 1), '2026-02-01');
      expect(DateKeys.addDays('2026-01-01', -1), '2025-12-31');
      expect(DateKeys.addDays('2024-02-28', 1), '2024-02-29');
      expect(DateKeys.addDays('2026-09-28', 0), '2026-09-28');
    });

    test('counts calendar days in both directions', () {
      expect(DateKeys.daysBetween('2026-09-21', '2026-09-28'), 7);
      expect(DateKeys.daysBetween('2026-09-28', '2026-09-21'), -7);
      expect(DateKeys.daysBetween('2023-03-01', '2024-03-01'), 366);
    });
  });

  group('DateKeys.forPrayer (prayer day starts at Fajr, 09 §2)', () {
    final fajr = DateTime(2026, 9, 28, 4, 45);

    test('Isha / Witr / Tahajjud before Fajr belong to yesterday', () {
      final at1am = DateTime(2026, 9, 28, 1);
      for (final p in [PrayerName.isha, PrayerName.witr, PrayerName.tahajjud]) {
        expect(
          DateKeys.forPrayer(prayer: p, now: at1am, todayFajr: fajr),
          '2026-09-27',
          reason: p.name,
        );
      }
    });

    test('other prayers before Fajr use today', () {
      expect(
        DateKeys.forPrayer(
          prayer: PrayerName.fajr,
          now: DateTime(2026, 9, 28, 1),
          todayFajr: fajr,
        ),
        '2026-09-28',
      );
    });

    test('Isha after Fajr uses today', () {
      expect(
        DateKeys.forPrayer(
          prayer: PrayerName.isha,
          now: DateTime(2026, 9, 28, 20),
          todayFajr: fajr,
        ),
        '2026-09-28',
      );
    });
  });

  group('DateKeys.isMarkable (D-075)', () {
    final now = DateTime(2026, 9, 28, 10);

    test('today and the previous 7 days are markable', () {
      expect(DateKeys.isMarkable('2026-09-28', now: now), isTrue);
      expect(DateKeys.isMarkable('2026-09-21', now: now), isTrue);
    });

    test('8 days back, the future and junk are not', () {
      expect(DateKeys.isMarkable('2026-09-20', now: now), isFalse);
      expect(DateKeys.isMarkable('2026-09-29', now: now), isFalse);
      expect(DateKeys.isMarkable('nope', now: now), isFalse);
    });
  });
}
