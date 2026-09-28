# Jaiza (Jaiza-Namaz)

Flutter app from **Al Islaah Academy** for tracking Fard, Nawafil, and Qaza prayers, with local Adhan-based prayer times, reminders, history, home widgets, and Parent / Organization attendance flows.

**Backend:** Firebase Authentication + Cloud Firestore.

## Documentation

- **[Project overview, architecture, improvements & Jamaat Timing feature](docs/PROJECT_OVERVIEW.md)** — full project report, including the proposed Mosque Jamaat (iqamah) feature
- [Home widget setup](WIDGET_SETUP.md)

## Getting started

```bash
flutter pub get
flutter run
```

Requires Firebase configured for your target platform (`lib/firebase_options.dart`, Android `google-services.json`, and iOS Firebase config as applicable).

## Stack

- Flutter + Riverpod + go_router  
- Firebase Auth & Cloud Firestore  
- `adhan_dart` for local prayer times  
- Local notifications & home widgets  
