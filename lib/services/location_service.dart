import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';

/// GPS for prayer times (coarse accuracy is enough for salāh times).
abstract final class LocationService {
  static Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Returns true if permission is granted (while-in-use or always).
  static Future<bool> requestWhenInUse() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  static Future<({double lat, double lon, String? label})?>
  getCurrentPosition() async {
    final ok = await requestWhenInUse();
    if (!ok) return null;
    final enabled = await isLocationServiceEnabled();
    if (!enabled) return null;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    final label = await labelForCoordinates(pos.latitude, pos.longitude);

    await HomeWidget.saveWidgetData(
      'jaiza_last_loc',
      '${pos.latitude},${pos.longitude},$label',
    );

    return (lat: pos.latitude, lon: pos.longitude, label: label);
  }

  static Future<String> labelForCoordinates(double lat, double lon) async {
    try {
      final places = await placemarkFromCoordinates(lat, lon);
      if (places.isNotEmpty) {
        final p = places.first;
        final parts =
            [
                  p.street,
                  p.subLocality,
                  p.locality,
                  p.subAdministrativeArea,
                  p.administrativeArea,
                  p.country,
                ]
                .whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        if (parts.isNotEmpty) {
          return _dedupe(parts).join(', ');
        }
      }
    } catch (_) {
      // Fall back to coordinates when reverse geocoding is unavailable.
    }
    return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
  }

  static List<String> _dedupe(List<String> parts) {
    final seen = <String>{};
    final out = <String>[];
    for (final p in parts) {
      final key = p.toLowerCase();
      if (seen.add(key)) out.add(p);
    }
    return out;
  }

  /// Last coords written by [getCurrentPosition] (comma-separated), if any.
  static Future<({double lat, double lon, String label})?>
  readCachedCoords() async {
    final raw = await HomeWidget.getWidgetData<String>(
      'jaiza_last_loc',
      defaultValue: '',
    );
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length < 2) return null;
    final lat = double.tryParse(parts[0]);
    final lon = double.tryParse(parts[1]);
    if (lat == null || lon == null) return null;
    final label = parts.length > 2 ? parts.sublist(2).join(',') : '$lat, $lon';
    return (lat: lat, lon: lon, label: label);
  }
}
