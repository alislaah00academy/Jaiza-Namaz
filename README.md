# Jaiza (Jaiza-Namaz)

Flutter app from **Al Islaah Academy** for tracking Fard, Nawafil, and Qaza prayers, with local Adhan-based prayer times, reminders, history, home widgets, and Parent / Organization attendance flows.

**Backend:** Firebase (Auth, Firestore database `jaiza` in asia-south1, Functions, Storage, App Check, Crashlytics, Analytics).

## Documentation

- **[System design — the source of truth](docs/system-design/00-README.md)** (build order: [18 Roadmap](docs/system-design/18-roadmap-and-migration.md))
- [Home widget setup](WIDGET_SETUP.md)
- [Old project overview](docs/PROJECT_OVERVIEW.md) (history only)

## Repo layout (monorepo, D-008)

- `lib/` — the Jaiza app (Android, iOS, Web)
- `packages/jaiza_core/` — shared pure-Dart models, enums and logic
- `functions/` (P1) and `admin_dashboard/` (P4) join later

## Getting started

```bash
flutter pub get                 # resolves the whole workspace
flutter run --dart-define=USE_EMULATORS=true
```

Day-to-day development **must** use the Firebase Emulator Suite (D-004), which needs Java 17+:

```bash
firebase emulators:start --import=./emulator-data --export-on-exit
```

Other `--dart-define`s: `EMULATOR_HOST` (your machine's LAN IP when running on a phone),
`RECAPTCHA_SITE_KEY` (App Check on web release builds), `APP_CHECK_DEBUG_TOKEN` (web debug).

## Code generation

Generated files are committed; CI fails if they are stale.

```bash
flutter gen-l10n                                   # after editing lib/core/l10n/arb/*.arb
cd packages/jaiza_core && dart run build_runner build --delete-conflicting-outputs
```

## Before you push

```bash
flutter analyze && dart run tool/check_l10n.dart && flutter test
cd packages/jaiza_core && dart test
```

- Every user-facing string goes in `lib/core/l10n/arb/app_en.arb` **and** `app_ur.arb` (16 §1).
- Use start/end layout (`EdgeInsetsDirectional` …), never left/right (16 §2).

## Stack

- Flutter + Riverpod 3 + go_router, freezed models
- Firebase Auth, Cloud Firestore, App Check, Crashlytics, Analytics
- English + Urdu (gen-l10n, RTL)
- `adhan_dart` for local prayer times  
- Local notifications & home widgets  
