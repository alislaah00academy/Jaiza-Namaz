# 17 — Other Features

## 1. Profile photo (D-092)
- Profile → avatar → *Take photo / Choose from gallery / Remove*.
- `image_picker` → `image_cropper` (square) → `flutter_image_compress` to JPEG, max 512×512,
  quality 80 (usually < 100 KB). Web: pick → compress in the browser (`image` package fallback, or
  upload the cropped PNG as is if the compress plugin isn't supported; rules allow ≤ 1 MB).
- Upload to `users/{uid}/avatar.jpg` with `SettableMetadata(contentType: 'image/jpeg', cacheControl: 'public,max-age=86400')`.
- Save `photoUrl = await ref.getDownloadURL()` plus `?v=<timestamp>` to bust caches, in `users/{uid}`.
- Show with `CachedNetworkImage`-like caching (or `Image.network` + a placeholder with initials).
- Remove: delete the file + `photoUrl: FieldValue.delete()`.
- Children's photos: later phase (same pattern under `children/{id}/photo.jpg`, guardian rules).

## 2. Donation (D-093)
- Screen: a short message from Al Islaah + the methods from Remote Config `donation_methods_json`
  (bank IBAN with a **Copy** button, JazzCash/Easypaisa numbers with Copy) + a **Donate online**
  button that opens `donation_url` in the browser (`url_launcher`, `LaunchMode.externalApplication`).
- No payment inside the app. Replaces the "Open donation (placeholder)" button.
- Store review: iOS/Android allow donations to registered non-profits through external links. The
  wording should make clear the money goes to Al Islaah Academy, not for app features. Recheck the
  current App Store Review Guideline 3.2.1 / Play payments policy before submitting.

## 3. Contact (D-094)
- Form (signed in only): category (bug / idea / mosque data / other), message (≤ 2000), optional
  "attach app info" (version, platform, mode — on by default). Write `feedback/{autoId}`
  (`status: 'new'`). Success: "JazakAllah, we received your message."
- Buttons (everyone): **WhatsApp** (`https://wa.me/<number>?text=<prefilled>`), **Email**
  (`mailto:`), both from Remote Config.
- Staff read and answer in the dashboard (14 §3).

## 4. About / Academy intro / Fazail
Static content (exists). Move all text to ARB (en + ur). The Urdu academy intro stays Urdu-first. Long
texts can live in `assets/content/{en,ur}/*.md`, rendered with a simple markdown widget, so the Academy
can update them without code changes (later: move to Firestore `content/` for updates without a release).

## 5. Announcements inbox (F-102)
More → Announcements: the latest 30 `announcements` (public read), newest first, in the app language.
Unread dot: compare with a local "last opened" timestamp (device only).

## 6. Analytics events (D-074)
Use a typed wrapper. **No personal data** in parameters (no names, emails, phones, CNIC, exact
locations).

| Event | Params |
|-------|--------|
| `sign_up` / `login` | `method` (password/google/apple/phone) |
| `mode_chosen` / `mode_switched` | `mode` |
| `prayer_marked` | `prayer`, `type`, `status`, `subject` (self/child/student), `source` |
| `qaza_logged` | `prayer`, `delta` |
| `mosque_saved` / `mosque_primary_set` | `city` |
| `mosque_search` | `kind` (nearby/name/city), `results` |
| `mosque_request_submitted` | `kind` |
| `jamaat_published` | `scheduled` (bool), `prayers_changed` |
| `report_submitted` | — |
| `child_added` / `guardian_joined` / `student_linked` | — |
| `org_created` / `teacher_invited` / `class_marked` | `students` (bucketed: 1–10, 11–30, 31+) |
| `report_card_generated` | `kind` (class/student), `period` |
| `guest_locked_feature_tap` | `feature` — shows which features make guests sign up |
| `notification_opened` | `type` |
| `app_error` (web) | `code`, `where` |

User properties: `active_mode`, `modes_count`, `app_language`, `has_primary_mosque`.

## 7. Force update & maintenance
- On start: if `buildNumber < remoteConfig.min_supported_build` → a blocking "Update Jaiza" screen with
  a store link (web: "Refresh").
- Needed during the data migration (18 §3), when old app versions must stop writing to old paths.

## 8. Settings summary (where each setting lives)
| Setting | Stored in |
|---------|-----------|
| Theme | device (`jz_theme_mode_v1`, exists) |
| Language | `users.locale` (+ device for guests) |
| Prayer method/madhab/location | `users.prayerSettings` (guest: device) |
| Reminder toggles N1/N2 | `users.prayerSettings` |
| Jama'at alerts N3 | `users.mosques.alerts` |
| Qaza reminder N4 | `users.qazaPlan.reminder` |
| Family reminders N5 | device (D-033) |
| Class reminders N6 | device (D-045) |
| Push toggles P1/P2 | `users.notificationPrefs` (+ topic reconcile) |
| Hijri adjustment | `users.prayerSettings.hijriAdjust` |
| Analytics opt-out | device + `setAnalyticsCollectionEnabled` |
