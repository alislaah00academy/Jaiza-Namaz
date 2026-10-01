# jaiza_core

Shared, **pure Dart** code for the Jaiza app and the admin dashboard (D-008, 03 §2):
enums, freezed models and pure logic (dateKey, log ids, …).

Rules:
- Never import Flutter or any Firebase package here (D-096). Dates are `DateTime`;
  the app converts `Timestamp`/`GeoPoint` in `lib/core/firestore/converters.dart`.
- Every enum field on a model uses `@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)`
  and every optional field has a default, so old app versions never crash on new data (04 §6).
- Logic that Cloud Functions also run (dateKey, streaks, Jama'at resolver) must stay in sync with
  `functions/src/lib` — shared JSON fixtures check this (18 §4).

Commands (from the repo root):

```bash
dart run build_runner build --delete-conflicting-outputs   # run inside packages/jaiza_core
dart test packages/jaiza_core
```

Generated `*.freezed.dart` / `*.g.dart` files are committed (04 §6).
