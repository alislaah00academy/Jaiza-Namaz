import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local/local_prefs.dart';
import '../../../data/models/prayer_log.dart';

/// A mosque with verified Jama'at times. There is no mosques backend yet,
/// so [kDemoMosques] is sample data; swapping it for a Firestore stream
/// later only needs [mosquesProvider] to change.
class Mosque {
  const Mosque({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.distanceKm,
    required this.jamaat,
    this.fiqh = 'Hanafi',
  });

  final String id;
  final String name;
  final String area;
  final String address;
  final double distanceKm;

  /// Jama'at time per Fard prayer as (hour 0–23, minute).
  final Map<PrayerName, (int, int)> jamaat;
  final String fiqh;

  String get distanceLabel => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  String get subtitle => '$area · $distanceLabel';

  /// "4:55" — compact 12h time without AM/PM, as on the Today rows.
  String shortTime(PrayerName p) {
    final t = jamaat[p];
    if (t == null) return '—';
    final h = t.$1 % 12 == 0 ? 12 : t.$1 % 12;
    return '$h:${t.$2.toString().padLeft(2, '0')}';
  }

  /// "04:45 PM".
  String longTime(PrayerName p) {
    final t = jamaat[p];
    if (t == null) return '—';
    final h = t.$1 % 12 == 0 ? 12 : t.$1 % 12;
    final ap = t.$1 < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${t.$2.toString().padLeft(2, '0')} $ap';
  }

  /// Today's Jama'at [DateTime] for [p].
  DateTime? jamaatOn(DateTime day, PrayerName p) {
    final t = jamaat[p];
    if (t == null) return null;
    return DateTime(day.year, day.month, day.day, t.$1, t.$2);
  }
}

const _standardTimes = <PrayerName, (int, int)>{
  PrayerName.fajr: (4, 55),
  PrayerName.zuhr: (12, 30),
  PrayerName.asr: (16, 45),
  PrayerName.maghrib: (18, 35),
  PrayerName.isha: (20, 0),
};

const List<Mosque> kDemoMosques = [
  Mosque(
    id: 'bilal',
    name: 'Masjid-e-Bilal',
    area: 'Gulshan-e-Iqbal',
    address: 'Block 5, Gulshan-e-Iqbal, Karachi',
    distanceKm: 0.4,
    jamaat: _standardTimes,
  ),
  Mosque(
    id: 'al-falah',
    name: 'Jamia Masjid Al-Falah',
    area: 'Block 13-D',
    address: 'Block 13-D, Gulshan-e-Iqbal, Karachi',
    distanceKm: 1.2,
    jamaat: {
      PrayerName.fajr: (5, 0),
      PrayerName.zuhr: (13, 15),
      PrayerName.asr: (16, 50),
      PrayerName.maghrib: (18, 33),
      PrayerName.isha: (20, 15),
    },
  ),
  Mosque(
    id: 'rahman',
    name: 'Masjid-e-Rahman',
    area: 'Block 10-A',
    address: 'Block 10-A, Gulshan-e-Iqbal, Karachi',
    distanceKm: 1.8,
    jamaat: {
      PrayerName.fajr: (4, 50),
      PrayerName.zuhr: (13, 0),
      PrayerName.asr: (16, 40),
      PrayerName.maghrib: (18, 34),
      PrayerName.isha: (20, 0),
    },
  ),
  Mosque(
    id: 'noor',
    name: 'Masjid-e-Noor',
    area: 'Johar Chowrangi',
    address: 'Johar Chowrangi, Gulistan-e-Johar, Karachi',
    distanceKm: 2.6,
    jamaat: {
      PrayerName.fajr: (5, 5),
      PrayerName.zuhr: (13, 30),
      PrayerName.asr: (17, 0),
      PrayerName.maghrib: (18, 36),
      PrayerName.isha: (20, 30),
    },
  ),
  Mosque(
    id: 'quba',
    name: 'Masjid-e-Quba',
    area: 'Nazimabad',
    address: 'Block 3, Nazimabad, Karachi',
    distanceKm: 3.1,
    jamaat: {
      PrayerName.fajr: (4, 45),
      PrayerName.zuhr: (13, 0),
      PrayerName.asr: (16, 45),
      PrayerName.maghrib: (18, 35),
      PrayerName.isha: (20, 0),
    },
  ),
  Mosque(
    id: 'madni',
    name: 'Madni Masjid',
    area: 'Gulistan-e-Johar',
    address: 'Block 7, Gulistan-e-Johar, Karachi',
    distanceKm: 3.4,
    jamaat: {
      PrayerName.fajr: (5, 0),
      PrayerName.zuhr: (13, 15),
      PrayerName.asr: (16, 55),
      PrayerName.maghrib: (18, 36),
      PrayerName.isha: (20, 15),
    },
  ),
  Mosque(
    id: 'bilal-korangi',
    name: 'Bilal Masjid',
    area: 'Korangi No. 5',
    address: 'Sector 5, Korangi, Karachi',
    distanceKm: 9.4,
    jamaat: _standardTimes,
  ),
];

/// All known mosques, nearest first.
final mosquesProvider = Provider<List<Mosque>>(
  (ref) =>
      [...kDemoMosques]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm)),
);

Mosque? mosqueById(String? id) {
  if (id == null) return null;
  for (final m in kDemoMosques) {
    if (m.id == id) return m;
  }
  return null;
}

/// The user's primary mosque, or null when none is linked yet.
final primaryMosqueProvider = Provider<Mosque?>(
  (ref) => mosqueById(ref.watch(primaryMosqueIdProvider)),
);

/// Case-insensitive search over name and area.
List<Mosque> searchMosques(List<Mosque> all, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return all;
  return all
      .where(
        (m) =>
            m.name.toLowerCase().contains(q) ||
            m.area.toLowerCase().contains(q) ||
            m.address.toLowerCase().contains(q),
      )
      .toList();
}
