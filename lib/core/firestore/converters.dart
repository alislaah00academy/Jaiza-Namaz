import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// The one place where Firestore types meet JSON models (04 §6).
///
/// `jaiza_core` models are pure Dart: dates are `DateTime` (ISO strings in
/// JSON) and geo points are `{lat, lng}` maps. Repositories run
/// [FirestoreJson.decode] on snapshot data before `Model.fromJson`, and
/// [FirestoreJson.encode] on `model.toJson()` before writing.
abstract final class FirestoreJson {
  /// Fields that the server owns. On [encode] their value is replaced by
  /// `FieldValue.serverTimestamp()` when [serverTimestamps] is on.
  static const Set<String> serverTimestampFields = {'createdAt', 'updatedAt'};

  /// Firestore data → JSON for `fromJson`: every [Timestamp] becomes an ISO-8601
  /// UTC string and every [GeoPoint] becomes `{lat, lng}`, at any depth.
  static Map<String, dynamic> decode(Map<String, dynamic> data) =>
      data.map((k, v) => MapEntry(k, _decodeValue(v)));

  /// JSON from `toJson` → Firestore data: ISO strings stay strings unless the
  /// key is listed in [dateFields] (then they become [Timestamp]s), and
  /// `{lat, lng}` maps under a key listed in [geoFields] become [GeoPoint]s.
  /// With [serverTimestamps], `createdAt`/`updatedAt` are set by the server
  /// (pass `false` for updates that must keep the original `createdAt`).
  static Map<String, dynamic> encode(
    Map<String, dynamic> json, {
    Set<String> dateFields = const {},
    Set<String> geoFields = const {},
    bool serverTimestamps = true,
  }) {
    final out = <String, dynamic>{};
    json.forEach((key, value) {
      if (serverTimestamps && serverTimestampFields.contains(key)) {
        out[key] = FieldValue.serverTimestamp();
      } else if (dateFields.contains(key) && value is String) {
        out[key] = Timestamp.fromDate(DateTime.parse(value));
      } else if (geoFields.contains(key) && value is Map) {
        out[key] = GeoPoint(
          (value['lat'] as num).toDouble(),
          (value['lng'] as num).toDouble(),
        );
      } else {
        out[key] = value;
      }
    });
    if (serverTimestamps) {
      for (final f in serverTimestampFields) {
        out.putIfAbsent(f, FieldValue.serverTimestamp);
      }
    }
    return out;
  }

  static Object? _decodeValue(Object? v) => switch (v) {
    Timestamp() => v.toDate().toUtc().toIso8601String(),
    GeoPoint() => {'lat': v.latitude, 'lng': v.longitude},
    Map() => v.map((k, e) => MapEntry(k as String, _decodeValue(e))),
    List() => v.map(_decodeValue).toList(),
    _ => v,
  };
}

/// For app-only freezed models (in a feature's `domain/`) that keep a
/// Firestore [Timestamp] field directly: `@TimestampConverter() DateTime? x`.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) => switch (json) {
    Timestamp() => json.toDate(),
    String() => DateTime.tryParse(json),
    int() => DateTime.fromMillisecondsSinceEpoch(json),
    _ => null,
  };

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}

/// `GeoPoint` ↔ `{lat, lng}` for app-only models.
class GeoPointConverter
    implements JsonConverter<GeoPoint?, Map<String, dynamic>?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Map<String, dynamic>? json) => json == null
      ? null
      : GeoPoint(
          (json['lat'] as num).toDouble(),
          (json['lng'] as num).toDouble(),
        );

  @override
  Map<String, dynamic>? toJson(GeoPoint? p) =>
      p == null ? null : {'lat': p.latitude, 'lng': p.longitude};
}
