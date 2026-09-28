# 18 — Roadmap, Migration, Testing, Release

## 1. Phases (build in this order)

Each phase ends with a release to internal testers (Play internal testing / TestFlight / a preview
Hosting channel). Rough sizes assume 1–2 developers.

| Phase | Scope | Size |
|-------|-------|------|
| **P0 Foundation** | Monorepo + `jaiza_core` (D-008) · FlutterFire upgrade (D-083) · Riverpod 3 bump with legacy imports (04 §8 step 1) · freezed setup · `bootstrap/` + emulators (15 §15) · App Check in monitor mode · Crashlytics/Analytics · ARB setup with existing strings moved · `firebase_options` + iOS plist fixed · CI | 1–2 weeks |
| **P1 Security & data model** | New rules + rules tests (07) · Functions project · `onUserCreated`/`ensureUserProfile` · move prayer logs to subcollections (D-072) · daily summaries/streak/qaza Functions (D-071) · migration script (§3) · min-version gate | 2 weeks |
| **P2 Auth & modes** | Google, Apple, Phone · account linking · guest mode + locked features + sign-in sheet · mode chooser + switcher + new redirect (05) · account deletion | 2 weeks |
| **P3 Mosques** | Real `mosques` collection · nearby (geohash) + search · follow/primary synced · local Jama'at reminders + budget scheduler (13 §3) · FCM + topics + change alerts · masjid admin mode + timetable editor + scheduled changes · reports | 3 weeks |
| **P4 Mosque requests + dashboard** | Registration with uploads + KMS CNIC · request status · admin dashboard v1 (requests, mosques, reports, staff, audit) · claim admin · co-admins | 3 weeks |
| **P5 Parent** | `children` top-level · age/gender · co-parent codes · family reminders on new data · madrasa link (needs P6 students) | 1.5 weeks |
| **P6 Organization** | Callables for org/invites/teachers · top-level `students` · class section · marking on new paths · PDF report cards · student link codes · verified badge (dashboard) | 3 weeks |
| **P7 Polish** | Urdu review + RTL pass · responsive/golden tests · profile photo · donation/contact via Remote Config · announcements · map view with Mapbox (feature flag) · performance · store listings | 2 weeks |

P5's madrasa link depends on P6's student model. Build P6's `students` collection before P5's link
step, or ship the link in P6.

## 2. Definition of done (every PR)
- Follows 03 (layers), 04 (Riverpod rules), 16 (l10n + overflow checklist).
- New Firestore paths → rules + rules tests. New queries → indexes in `firestore.indexes.json`.
- Unit tests for logic, widget tests for new screens, golden tests for key screens.
- Analytics events added where listed in 17 §6.
- No `print`; use `appLog`. No new `StateNotifier`/`StateProvider`.
- Docs updated if behaviour changed (and a new decision added if a decision changed).

## 3. Data migration (from the current structure)

**First, answer: does the live project have real users' data?**
- **No (only test data):** skip the script. Export once for safety, delete the old collections, deploy
  the new rules, and start clean.
- **Yes:** follow these steps.

1. **Plan the cut-over**: don't build an app version that writes to both old and new paths (too
   complex). Instead, run the migration in a quiet hour (e.g. 02:00 PKT) and force old apps to update
   at step 5 with Remote Config `min_supported_build`. **Important:** the current app has no
   min-version check, so ship one build with the check (17 §7) **before** the migration build.
2. **Backup**: `gcloud firestore export gs://jaiza-namaz-backups/pre-migration-$(date +%F)`.
3. **Run** `functions/scripts/migrate_v2.ts` (Admin SDK, idempotent, resumable, logs counts):
   ```
   for each users/{uid}:
       modes from role/orgMemberRole (05 §4.2); lastMode = role; onboardedModes = role != null
       prayerSettings defaults fill-in; mosques = {} ; remove legacy fields (role, orgId, orgMemberRole)
       trackingSince = min(createdAt dateKey, earliest log dateKey)
   for each users/{uid}/children/{cid}:
       create children/{cid} {name, guardianUids:[uid], createdBy:uid, trackingSince, …}
   for each organizations/{o}/classes/{c}/students/{s}:
       create students/{s} {orgId:o, classId:c, teacherUid, name, active:true, guardianUids:[], orgName, className}
   for each prayers/{id}:  (id = {userId}_{dateKey}_{prayer}_{type})
       subject = users/{userId} if exists
              else children/{userId} if migrated
              else students/{userId} if migrated
              else → log "orphan", skip
       write {subject}/prayers/{dateKey}_{prayer}_{type} with dateKey, markedBy = ownerUid ?? userId, source
       (qaza logs: count = 1 per old doc, summed per day)
   then: trigger a full recompute of dailySummaries / stats (script calls the same lib as recomputeDay)
   ```
4. **Verify**: counts per collection match (old vs new), spot-check 10 users, 3 children, 1 class.
5. **Switch**: deploy the new rules + Functions, then publish Remote Config `min_supported_build`.
6. **Device data**: on first launch of the new app, migrate device-only prefs once:
   `jz_primary_mosque_v1`/`jz_saved_mosques_v1`/`jz_jamaat_alert*` → `users.mosques` (demo mosque ids
   like the ones in `kDemoMosques` are **dropped**, since they don't exist in Firestore);
   `jz_child_extras_v1` → `children.birthYear/gender`; `jz_class_sections_v1` → `classes.section`;
   `jz_tracking_since_v1` → ignored (server value wins); `jz_qaza_remind_daily_v1` → `qazaPlan.reminder`.
7. **Clean up** after 30 days: delete top-level `prayers`, `streaks`, old subcollections; remove the
   migration code paths from the app.

## 4. Testing strategy

| Layer | Tool | What |
|-------|------|------|
| Pure logic (`jaiza_core`) | `dart test` | dateKey, day boundary, Jama'at resolver (fixed/after-azan/upcoming), Qaza math, streak math, keyword builder |
| Cross-language parity | shared JSON fixtures | Dart and TS produce the same Jama'at times, dateKeys, streaks |
| Functions | jest + emulators | each callable: happy path + every error code; triggers idempotent (run twice → same result) |
| Rules | `@firebase/rules-unit-testing` | 07 §4 list |
| App notifiers | `ProviderContainer.test` + fakes | marking, follow, mode switching, redirect table |
| Widgets | `flutter_test` | key screens, locked-feature sheet, mode chooser |
| Golden | `matchesGoldenFile` | 16 §3.3 |
| Integration | `integration_test` against emulators | sign up → verify (emulator) → choose Parent → add child → mark → see summary |
| Manual | checklist per release | notifications on real devices (Android 14, a Xiaomi, iPhone), widgets, offline mode, phone OTP with a real SIM |

## 5. Release checklist
- [ ] Version bump (`pubspec.yaml` `version: x.y.z+build`), `min_supported_build` reviewed
- [ ] `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols` → upload symbols
- [ ] `flutter build ipa --release --obfuscate --split-debug-info=build/symbols`
- [ ] `flutter build web --release` (app) + dashboard → `firebase deploy --only hosting`
- [ ] Functions/rules/indexes deployed **before** the app release when they're backwards compatible
- [ ] Store: screenshots in en + ur, privacy labels, data safety, account deletion link, content
      rating, "Designed for families" questions (children's data — **read Google Play's Families policy**:
      the app isn't aimed at children, but it stores children's info entered by parents; declare it)
- [ ] Smoke test on real devices after the store build

## 6. Things still to confirm before coding (small, but they block setup)
1. **Final Android applicationId and iOS bundle id** (15 §3) — they can't change after the store
   release.
2. **Current Firestore region** (15 §2.3) — if it isn't `asia-south1`, pick option (a) or (b).
3. **Does the live project have real users?** Decides §3 (migrate vs start clean).
4. **Apple Developer account** (paid, USD 99/yr) under Al Islaah or the owner — needed for Apple sign-in,
   APNs, App Attest.
5. **Who are the first platform admins** (emails) and who translates/reviews Urdu text.
6. **Privacy policy owner** — someone at Al Islaah must approve the CNIC/children's data wording.
7. **Mapbox account & token** (only when the map view starts, P7).
8. **Email sending for teacher invites** (optional): an SMTP account for the Trigger Email extension.
