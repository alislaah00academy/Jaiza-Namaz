# Jaiza Home Widget Setup (iOS + Android)

This repo already contains:

- Flutter bridge code (`home_widget`) and deep-link handling
- Android widget provider + layout + manifest entries
- iOS WidgetKit scaffold files under `ios/JaizaPrayerWidget/`

## iOS manual target setup (required once)

Because Flutter iOS projects are Xcode-managed, the Widget Extension target must be created in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. File → New → Target → **Widget Extension**.
3. Name it exactly: `JaizaPrayerWidget`.
4. Replace generated Swift and plist files with:
   - `ios/JaizaPrayerWidget/JaizaPrayerWidget.swift`
   - `ios/JaizaPrayerWidget/Info.plist`
5. In Signing & Capabilities, enable **App Groups** on:
   - `Runner` target
   - `JaizaPrayerWidget` target
6. Add the same App Group on both targets:
   - `group.com.alislaacademy.jayzanamaz.jaizaNamaz`
7. For the widget target, set entitlements file to:
   - `ios/JaizaPrayerWidget/JaizaPrayerWidget.entitlements`

## Deep-link contract

Widget buttons call:

- `jaiza://prayer/mark?name=fajr&status=completed`
- `jaiza://prayer/mark?name=fajr&status=missed`

Runner receives this URL scheme and Flutter handles it in `HomeWidgetBridge.handleLaunchUri`.

## Android notes

Android setup is already wired:

- Provider: `JaizaPrayerWidget` (`AndroidManifest.xml`)
- Layout: `android/app/src/main/res/layout/jaiza_prayer_widget.xml`
- Metadata: `android/app/src/main/res/xml/jaiza_prayer_widget_info.xml`

No additional Android Studio setup is required.
