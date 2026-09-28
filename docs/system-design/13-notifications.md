# 13 — Notifications (local + push)

## 1. All notification types

| # | Type | Local / Push | Platforms | Channel id (Android) | Default |
|---|------|--------------|-----------|---------------------|---------|
| N1 | Prayer window **start** | Local | Android, iOS | `prayer_start` | on |
| N2 | Prayer window **ending** (10 min before) | Local | Android, iOS | `prayer_end` (exists as `jaiza_prayer_end`) | on |
| N3 | Jama'at in X min (followed mosques) | Local | Android, iOS | `jamaat_reminder` | on for the primary mosque, 10 min |
| N4 | Qaza daily reminder | Local | Android, iOS | `qaza_reminder` | off until the plan is set |
| N5 | Family: child's prayer not marked | Local | Android, iOS | `family_reminder` | on when Parent mode is active |
| N6 | Teacher: class not marked | Local | Android, iOS | `class_reminder` | off |
| P1 | Jama'at **changed** / changes tomorrow | Push (topic) | Android, iOS, Web | `jamaat_changes` | on for saved mosques |
| P2 | Announcements from Al Islaah | Push (topic) | Android, iOS, Web | `announcements` | on |
| P3 | Mosque request decision | Push (token) | all | `account` | on |
| P4 | New report for my mosque (admins) | Push (token) | all | `account` | on |
| P5 | Teacher invite / removed / org verified | Push (token) | all | `account` | on |
| P6 | Co-parent joined your child | Push (token) | all | `account` | on |

Every type has its own toggle in **Settings → Notifications** (`/app/settings/notifications`).
Android channels let users mute each type in system settings too.

## 2. Push (FCM)

### 2.1 Setup summary (details in 15 §6)
Android: nothing extra beyond `google-services.json` · iOS: APNs **auth key (.p8)** uploaded to
Firebase, Push Notifications + Background Modes (remote notifications) capabilities · Web: VAPID key +
`web/firebase-messaging-sw.js`.

### 2.2 Token registration (`PushService`)
```dart
Future<void> registerToken(String uid) async {
  final settings = await FirebaseMessaging.instance.requestPermission(); // only after the user opts in (see 2.3)
  if (settings.authorizationStatus == AuthorizationStatus.denied) return;
  final token = await FirebaseMessaging.instance.getToken(vapidKey: kIsWeb ? Env.vapidKey : null);
  if (token == null) return;
  await firestore.doc('users/$uid/devices/${await DeviceId.get()}').set({
    'token': token, 'platform': platformName, 'locale': locale, 'appVersion': version,
    'lastSeenAt': FieldValue.serverTimestamp(),
  });
  FirebaseMessaging.instance.onTokenRefresh.listen((t) => /* same write */);
}
```
Write `lastSeenAt` at most once per day (to save writes).

### 2.3 Permission timing
Never ask on first launch. Ask when the user: saves a mosque, turns on any reminder, or finishes the
mode chooser — after an in-app explainer sheet ("Jaiza will remind you before each prayer…").
Android 13+ needs `POST_NOTIFICATIONS` at runtime (`permission_handler` or FCM's `requestPermission`).

### 2.4 Topics
| Topic | Who subscribes | How |
|-------|----------------|-----|
| `mosque_{mosqueId}` | Anyone who saved that mosque and has change alerts on | mobile: `subscribeToTopic`; web: callable `subscribeWebTopics` |
| `announcements_en` / `announcements_ur` | Everyone with announcements on, by app language | same; switch topic when the language changes |

Keep a local set of "topics I subscribed" (prefs) and **reconcile** it on every app start with what
it should be (saved mosques + settings). This fixes drift after reinstalls or failed calls.

### 2.5 Receiving
- Foreground: FCM doesn't show a system notification on its own → show it with
  `flutter_local_notifications` (same channel) + an in-app banner.
- Background/terminated: the system shows the `notification` part. The `onBackgroundMessage`
  handler (a top-level function with `@pragma('vm:entry-point')`) handles `data.kind`:
  - `jamaatChanged` → fetch `mosques/{id}` (from the server) and **reschedule** that mosque's N3
    reminders.
- Tap → `data.route` → `GoRouter.go(route)` (also for the terminated case via `getInitialMessage()`).
- Announcements are also saved in `announcements/` so the inbox (F-102) shows the last 30.

## 3. Local notifications and the budget scheduler (D-065)

### 3.1 Why a budget
iOS keeps **at most 64 pending** local notifications per app and silently drops the rest. Android
has no hard limit, but exact alarms are limited (§4). One day can need up to:
5 (N1) + 5 (N2) + 5 × followed mosques (N3) + 1 (N4) + 5 × children (N5) + N6. Three mosques and
two children = 36 per day, so 2 days already exceed 64.

### 3.2 Algorithm (`NotificationScheduler.reschedule()`)
```
inputs: settings, today's + next days' prayer schedules, effective Jama'at per followed mosque,
        children & family prefs, classes & teacher prefs, qaza plan
1. Build candidates for the next 72 hours: (fireAt, type, id, payload).
2. Drop candidates in the past, already satisfied (prayer already marked), or in quiet hours.
3. Sort by fireAt; priority tie-break: N2 > N3 > N1 > N5 > N4 > N6.
4. Keep the first 60 (iOS) / 150 (Android). Leave room for foreground push display.
5. Diff against pending (flutter_local_notifications.pendingNotificationRequests()):
   cancel the ones not in the new set, schedule new ones. IDs are stable ints:
   hash(type, subjectId, dateKey, prayer) & 0x7fffffff.
```
Called when: the app opens/resumes, settings change, a prayer is marked, a mosque is saved/unsaved,
a `jamaatChanged` push arrives, location changes, and on iOS through a **background fetch** (best
effort). Replaces the current `rescheduleFromSchedules` (rolling ~3 days).

### 3.3 Time zones
Use `timezone` + `flutter_timezone` (exists): `tz.setLocalLocation(await FlutterTimezone.getLocalTimezone())`,
and `zonedSchedule(... androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle)` when exact
alarms are allowed, else `inexactAllowWhileIdle`.

## 4. Android exact alarms
- Android 12+ needs `SCHEDULE_EXACT_ALARM` (the user can revoke it); Android 14+ does **not** grant it
  by default to new installs. `USE_EXACT_ALARM` is only for alarm/clock/calendar apps under Play policy —
  **don't** declare it unless Play approves the app as that category.
- Flow: check `canScheduleExactNotifications()`. If false, show a card in Notification settings:
  "For on-time prayer reminders, allow *Alarms & reminders*" → open the system settings page.
  Without it, reminders may arrive a few minutes late (inexact) — acceptable fallback.
- Keep the receivers in `AndroidManifest.xml` for `flutter_local_notifications`
  (`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` with `RECEIVE_BOOT_COMPLETED`)
  so reminders survive reboots.
- Some brands (Xiaomi/MIUI, Oppo, Vivo, Huawei) kill background apps. Add a help screen "Reminders
  not arriving?" with steps (autostart, battery "no restrictions").

## 5. Modes and notifications
Reminders belong to **data**, not to the open mode: a parent in Individual mode still gets family
reminders, and a teacher in Parent mode still gets class reminders — as long as that mode exists and
its reminders are on. Tapping a notification switches to the right mode automatically
(05 §6.2, row 12).

## 6. Web
- No local scheduled reminders (N1–N6) and no widgets (D-066). Settings hide those toggles and show
  "Reminders are available in the mobile app".
- Push P1–P6 works when the browser allows it (iOS Safari only for a PWA added to the home screen).
- `web/firebase-messaging-sw.js`:
```js
importScripts('https://www.gstatic.com/firebasejs/<same-major-as-FlutterFire>/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/<same-major-as-FlutterFire>/firebase-messaging-compat.js');
firebase.initializeApp({ /* web config from firebase_options.dart */ });
firebase.messaging();
```
