# 01 — Decision Log

Every decision below is **final** unless a newer decision replaces it. To change one, add a new row
(e.g. `D-071 replaces D-032`) with the date and reason. Never edit an old decision's meaning.

Legend: **Owner** = decided by the product owner (Hamza). **Tech** = technical decision made in this
design, based on the owner's goals.

---

## A. Platforms, backend, environments

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-001 | The app ships on **Android, iOS and Web**. macOS/Windows/Linux folders may stay in the repo but are not supported or tested. | Owner's target platforms. | Owner |
| D-002 | The backend is **Firebase only**: Auth, Cloud Firestore, Cloud Storage, Cloud Functions (2nd gen), FCM, Remote Config, App Check, Analytics, Crashlytics, Hosting, Cloud KMS. No other server. | One vendor, one bill, and it fits the current code. | Owner |
| D-003 | There is **one Firebase project** (`jaiza-namaz`) for both development and production. | Owner's choice (simpler, cheaper). | Owner |
| D-004 | Because of D-003, all day-to-day development and testing **MUST** use the **Firebase Local Emulator Suite** (Auth, Firestore, Functions, Storage). Only release testing touches the real project. Test accounts on the real project MUST use emails ending in `+test@…` and are cleaned by a script. | With one project, a bad test or a broken rule would hit real users. Emulators remove that risk for free. | Tech |
| D-005 | The project uses the **Blaze (pay-as-you-go) plan** with **budget alerts** at USD 10, 25 and 50 per month. | Cloud Functions, outbound FCM from Functions, KMS and phone SMS need Blaze. | Owner |
| D-006 | Firestore, Functions and Storage live in region **`asia-south1` (Mumbai)**. ⚠️ A Firestore database's region **cannot be changed** after creation. If the current database is already in another region, keep it and put Functions in the nearest region to it (see 15 §2.3). | Lowest latency for Pakistan. | Owner |
| D-007 | Cloud Functions are written in **TypeScript** (Node.js 22, 2nd gen). | The owner prefers Dart if possible. When this was written, Dart support for Cloud Functions for Firebase was still experimental. It did not cover everything we need in production (Firestore triggers, scheduled jobs, callables with App Check, Admin SDK features such as custom claims and KMS). TypeScript is the official, fully supported option. **Revisit when Dart support is GA.** | Tech |
| D-008 | The repo becomes a **monorepo** with Dart **pub workspaces**: the app (root), `admin_dashboard/` (Flutter web), `packages/jaiza_core/` (shared models + pure logic), `functions/` (TypeScript). | The dashboard and the app must share the exact same models, enums and schedule math. | Tech |
| D-009 | **App Check is enforced** on Firestore, Storage and Functions (Play Integrity on Android, App Attest on iOS, reCAPTCHA Enterprise on web). The emulator and debug builds use debug tokens. | Guests can read mosque data without signing in, so we need another way to block scripts and scrapers. | Tech |

## B. Accounts, modes, guest

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-010 | One account can hold **several modes at the same time**: Individual, Parent, Organization (admin **or** teacher), Masjid Admin. | Owner requirement. | Owner |
| D-011 | Every account **always has Individual mode**. The other modes are unlocked by an action: Parent (add or join a child), Organization (create a madrasa or accept a teacher invite), Masjid Admin (approved by Al Islaah). | Everyone prays, so personal tracking is the base of every account. | Tech |
| D-012 | Switching modes **never changes or deletes** any data. Each mode's data is stored separately (see 06). | Owner requirement. | Owner |
| D-013 | **First login** shows the **Mode chooser** with all 4 modes. After that, the app opens in the **last used mode**. A "Switch mode" control is always visible (header chip + More screen). | Owner choice. | Owner |
| D-014 | "Switch account" means **switching modes inside one login**, not holding several Firebase logins on one phone. | Owner choice. | Owner |
| D-015 | The last used mode is saved **on the device** (SharedPreferences) **and** in `users/{uid}.lastMode`, so a new device opens in the same mode. | Opens instantly offline and syncs across devices. | Tech |
| D-016 | Mode-granting fields (`orgId`, org role, masjid admin list, platform role) are **written only by Cloud Functions**, never by the client. | The current rules let a user write their own `role`/`orgId`, and some invite rules can be abused (see 07 §1). | Tech |
| D-017 | **Guest mode**: without signing in, a user can **see** every feature (shown with a lock and a "Sign in to use" sheet), but can only **use**: mosque search/nearby, mosque details and Jama'at times, and calculated namaz times **if they share location** (or pick a city by hand). | Owner requirement. The manual city picker is the fallback for web and for users who deny location. | Owner + Tech |
| D-018 | Guests do **not** get a Firebase account (no Anonymous Auth). Guest data (saved mosques, Jama'at alerts, location choice) lives on the device. It is **uploaded to the new account** on sign-up. | Anonymous accounts pile up and need clean-up jobs. Approved-mosque data is public-read, protected by App Check (D-009). | Tech |
| D-019 | Guests **may** get Jama'at-change push alerts for saved mosques (FCM topics need no login). They may **not** report mosques, register mosques or send feedback. | Alerts cost almost nothing and are the main hook to get guests to sign up. Writes need an identity. | Tech |

## C. Authentication

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-020 | Sign-in methods: **Email + password, Google, Apple, Phone (SMS OTP)**, on all 3 platforms. | Owner requirement. Apple is also required by App Store rule 4.8 when Google is offered. | Owner |
| D-021 | Email/password accounts **must verify their email** before entering the app (as today). Google/Apple emails count as verified. Phone accounts have no email gate. | Keeps today's behaviour and avoids fake emails. | Tech |
| D-022 | Firebase setting **"One account per email address"** stays ON. If the email already exists with another provider, the app asks the user to sign in with the old method and then **links** the new one. | Prevents duplicate accounts and data split across two uids. | Tech |
| D-023 | Phone OTP is limited by an **SMS region policy (allow only Pakistan, +92)** in v1, plus App Check. | SMS costs money and is a common fraud target ("SMS pumping"). | Tech |
| D-024 | **Account deletion**: from Profile → Delete account. The user sees a full-screen warning listing everything that will be deleted, types `DELETE`, and **re-authenticates** (password, or Google/Apple/phone OTP for those accounts). A Cloud Function then deletes everything. | Owner requirement. Google Play and the App Store both require in-app deletion. | Owner |

## D. Parent mode

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-030 | Children **do not sign in** in v1. The data model allows a child to get their own login later (`children/{id}.linkedUid`). | Owner choice. | Owner |
| D-031 | A child can be managed by **up to 4 guardians** (for example mother and father). A guardian joins using a **one-time invite code** from an existing guardian. The code is valid for 48 hours. | Owner choice. | Owner |
| D-032 | A child's **age and gender** move to Firestore. Age is stored as **`birthYear`** (the UI still asks "age"), so it never goes stale. | Owner choice. Storing a plain age number would be wrong a year later. | Owner + Tech |
| D-033 | Family reminders ("child hasn't prayed Asr") are **local notifications on each guardian's phone**. | Owner choice. They work offline and cost nothing. | Owner |
| D-034 | Parents can see their child's **madrasa attendance** (read-only) by entering a **student link code** that the teacher gives them. See 11 §5. | Owner requirement. | Owner + Tech |

## E. Organization (madrasa) mode

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-040 | **Anyone** can create an organization. Al Islaah can give it a **Verified badge** from the admin dashboard. | Owner choice. | Owner |
| D-041 | Teachers join **only by email invite** (the current flow). Claiming an invite moves to a **Cloud Function** that checks the signed-in email matches. | Owner choice. The move fixes a security hole (07 §1). | Owner + Tech |
| D-042 | Students **do not log in**. Only linked **parents** get read access to a student's attendance. | Owner choice. | Owner |
| D-043 | A teacher belongs to **exactly one** organization. An org admin owns **exactly one** organization and **may also teach** classes in it. | Owner choice. Keeps rules and UI simple. | Owner |
| D-044 | Class reports: a well-designed **PDF report card, made on the device**, weekly and monthly, per class and per student. | Owner choice. | Owner |
| D-045 | Class **section** moves to Firestore. Teacher "unmarked class" reminders stay **local**. | Owner choice. | Owner |
| D-046 | Students move to a **top-level `students` collection** (they used to be nested under classes). | Parent links and simple rules need one place to look a student up. Moving a student to another class becomes a single field change. | Tech |

## F. Mosques and Jama'at

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-050 | Any **signed-in** user can request a new mosque. It stays **pending** until Al Islaah approves or rejects it. Only approved mosques are public. | Owner choice. | Owner |
| D-051 | Reviews happen in a **separate Flutter web admin dashboard** (see 14). | Owner choice. | Owner |
| D-052 | The **CNIC number is stored encrypted** with **Cloud KMS**, using a Cloud Function. It is never stored in plain text or sent back to any client. The last 4 digits are stored in plain text for display. Proof documents go to **private Cloud Storage**. See 10 §4. | Owner wants to keep CNIC. Encryption plus strict access and an audit log is the safe way to do that. | Owner + Tech |
| D-053 | A mosque has **up to 3 admins**. The first approved one is the **primary admin** and can invite or remove the other two. Al Islaah can change anything. | Owner choice. | Owner |
| D-054 | Each Fard Jama'at time is either **fixed** (`05:15`) or **"N minutes after azan"** (0–60). Azan for a mosque is calculated at the mosque's location with the mosque's method/madhab. | Owner choice. Maghrib is almost always "after azan". | Owner |
| D-055 | **Jumu'ah: up to 3 times.** Eid, Taraweeh and Ramadan timetables are **out of scope** for now. | Owner choice. | Owner |
| D-056 | Admins can **schedule future changes** with a start date ("from Mon 3 Nov, Fajr 05:30"). The app shows the upcoming change in advance and switches on that date by itself. | Owner choice. | Owner |
| D-057 | Nearby search uses **geohash** queries in Firestore (`geoflutterfire_plus`). Name search uses a prefix-keyword array. A **map view** comes later and will use **Mapbox** tiles through `flutter_map` (works on Android, iOS and web). | Owner asked whether a paid Mapbox key works. Yes, for **showing maps, dropping pins and turning addresses into coordinates**. The "which mosques are near me" query still runs in Firestore for free, so we don't pay Mapbox for every search. | Owner + Tech |
| D-058 | Users can **report a wrong time**. The report goes to that mosque's admins (push + a list in their panel) and to the admin dashboard if not handled in 7 days. | Owner choice. | Owner |
| D-059 | **Pakistan only** in v1 (`country = 'PK'`, timezone `Asia/Karachi`). The schema already stores country and timezone, so other countries need no migration. | Owner choice. | Owner |
| D-060 | An admin's edits are saved as **one "Publish changes" action** (one write), so followers get **one** notification per publish, not one per field. | Stops notification spam. | Tech |

## G. Notifications

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-061 | Jama'at **changes** trigger a **push (FCM)** to the followers of that mosque, through the **topic** `mosque_{mosqueId}`. | Owner choice. Topics scale without us storing follower lists for sending. | Owner + Tech |
| D-062 | Jama'at **"X minutes before"** reminders are **local notifications**, scheduled from the saved timetable. They work offline. | Owner choice. | Owner |
| D-063 | Qaza reminders: **daily, at a time the user picks**. (Weekly/monthly options in the current enum stay hidden until later.) | Owner choice. | Owner |
| D-064 | Al Islaah can send **announcements** to everyone through FCM topics `announcements_en` / `announcements_ur` from the dashboard. | Owner choice. | Owner |
| D-065 | A **notification budget scheduler** decides which local notifications to schedule, because iOS allows only **64 pending** local notifications per app. See 13 §3. | Without it, iOS silently drops reminders. | Tech |
| D-066 | On web, local scheduled reminders and home widgets are **hidden**. Web still gets FCM push (change alerts + announcements). | Browsers can't schedule local notifications reliably. | Owner |

## H. Data, sync, stats

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-070 | Prayer marking **works fully offline** (Firestore offline cache) and syncs later. Web turns on persistent cache explicitly. | Owner choice. | Owner |
| D-071 | **Streaks, badges, daily summaries and Qaza counters are calculated by Cloud Functions** and are **read-only** for clients. | Owner choice: they can't be faked, and they stay the same on every device. | Owner |
| D-072 | Prayer logs move from the top-level `prayers` collection to **subcollections under each subject**: `users/{uid}/prayers`, `children/{id}/prayers`, `students/{id}/prayers`. | Rules become simple and provable (access is decided by the parent document). The current top-level design with OR-conditions can make list queries fail against rules, and it lets admins guess other logs. | Tech |
| D-073 | Settings that **sync** across devices: primary/saved mosques, Jama'at alert settings, Qaza reminder, prayer settings, profile. Settings that **stay on the device**: theme, onboarding seen, last tab, notification permission state. | Owner choice. | Owner |
| D-074 | **Firebase Analytics + Crashlytics** are added. Crashlytics runs on Android/iOS only (it doesn't support web); web errors go to Analytics as `app_error` events. | Owner choice. | Owner |
| D-075 | Marking (or changing) a prayer is allowed for **today and the previous 7 days** only, for every subject type. Future dates are rejected by rules. | Stops accidental or fake back-filling. Also limits how much the streak function has to recompute. | Tech |

## I. Code

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-080 | State management: **Riverpod 3**, using `Notifier` / `AsyncNotifier` / `StreamNotifier`, **without code generation**. Migrate from `StateNotifier`/`StateProvider` **gradually**, one feature at a time. | Owner choice. | Owner |
| D-081 | Models use **`freezed` + `json_serializable`**, with shared converters for `Timestamp`, `GeoPoint` and enums. | Tech (owner asked me to decide). Jaiza has around 25 models with many optional fields, `copyWith` and nested maps. Hand-written `fromMap/toMap` already has duplicated code (for example `AppUser.fromSnapshot` and `fromJson` are near copies), and new fields get missed. freezed gives equality, `copyWith`, sealed unions (e.g. `JamaatRule.fixed \| afterAzan`) and JSON in one place. The cost is `build_runner`, which only runs for models, not for providers. | Tech |
| D-082 | Folder structure: **feature-first**, each feature split into `data/`, `domain/`, `presentation/` (see 03). | Owner choice. | Owner |
| D-083 | Upgrade FlutterFire packages to the **latest stable majors** in one PR before the backend work (check pub.dev on the day). Pin exact versions in `pubspec.lock`. | The project is on older majors (`firebase_core` 3.x). New features (App Check, Functions, Messaging) should start on current APIs. | Tech |
| D-084 | Remove unused dependency `android_alarm_manager_plus` (it is never called), unless 13 §4 later needs it. | Dead dependency, and it adds permissions. | Tech |

## J. UI, language, other features

| ID | Decision | Why | By |
|----|----------|-----|----|
| D-090 | Languages: **English + Urdu**, with full **RTL** for Urdu, using Flutter `gen-l10n` + ARB files. The user picks the language in Profile; the default follows the device. | Owner choice. | Owner |
| D-091 | **No screen may overflow.** Every screen must pass the checks in 16 §5 (320 px width, Urdu, text scale 1.5, landscape, web desktop width). | Owner requirement. | Owner |
| D-092 | Profile photos use **Firebase Storage**, compressed on the device to at most 512×512 JPEG. | Owner choice. | Owner |
| D-093 | Donation opens an **external link** (a URL and bank/JazzCash/Easypaisa details set in **Remote Config**). No in-app payments. | Owner said "you decide". It avoids store payment rules and fees. Donation links for a registered charity are allowed. **Check with each store's current policy before release.** | Tech |
| D-094 | Contact: an in-app form saved to Firestore `feedback`, plus WhatsApp and email buttons (numbers/addresses from Remote Config). | Owner said "you decide". Messages can't be lost, and staff can read them in the dashboard. | Tech |
| D-095 | Default prayer calculation for Pakistan: **Karachi (University of Islamic Sciences) method + Hanafi Asr**. The current default (Muslim World League + Mecca coordinates) is only used outside Pakistan. | Most Pakistani mosques follow Karachi/Hanafi. | Tech |
