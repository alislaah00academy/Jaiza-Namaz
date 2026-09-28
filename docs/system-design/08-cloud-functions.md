# 08 — Cloud Functions (TypeScript, 2nd gen)

## 1. Project setup

```
functions/
├── package.json            # "engines": { "node": "22" }
├── tsconfig.json
├── .eslintrc.js
├── src/
│   ├── index.ts            # exports only; one line per function
│   ├── config.ts           # region, secrets, constants
│   ├── lib/                # shared helpers
│   │   ├── admin.ts        # initializeApp(), db, auth, messaging, storage
│   │   ├── guards.ts       # requireAuth, requirePlatform, requireAppCheck
│   │   ├── dateKey.ts      # dateKey math per timezone (luxon)
│   │   ├── codes.ts        # link code generator
│   │   ├── kms.ts          # CNIC encrypt/decrypt
│   │   ├── fcm.ts          # sendToTopic, sendToUser
│   │   ├── jamaat.ts       # effective schedule resolver (mirror of jaiza_core)
│   │   └── audit.ts
│   ├── auth/               # onUserCreated, ensureUserProfile, deleteAccount
│   ├── prayers/            # onPrayerWritten → summaries, streaks, qaza
│   ├── family/             # createGuardianCode, redeemGuardianCode, removeChild, removeGuardian, childCount
│   ├── org/                # createOrganization, acceptTeacherInvite, removeTeacher, transferOrg,
│   │                       # createStudentLinkCode, redeemStudentLinkCode, unlinkStudent, removeStudent,
│   │                       # requestOrgVerification, counts
│   ├── mosques/            # submitMosqueRequest, withdraw, reviewMosqueRequest, onMosqueWritten,
│   │                       # applyDueJamaatChanges, remindTomorrowChanges, inviteMosqueAdmin,
│   │                       # acceptMosqueAdminInvite, removeMosqueAdmin, onReportCreated,
│   │                       # escalateReports, followerCounts
│   ├── platform/           # setPlatformRole, revealCnic, sendAnnouncement, verifyOrganization
│   ├── push/               # subscribeWebTopics, cleanupTokens
│   └── maintenance/        # purgeExpiredCodes, purgeCnic, backups
├── scripts/                # ts-node admin scripts (migrations, seeding, first superAdmin)
└── test/                   # jest + emulator; rules tests in test/rules
```

Global options (`src/config.ts`):
```ts
import { setGlobalOptions } from 'firebase-functions/v2';
setGlobalOptions({ region: 'asia-south1', maxInstances: 10, memory: '256MiB' });
export const TZ_PK = 'Asia/Karachi';
```

Libraries: `firebase-admin`, `firebase-functions`, `@google-cloud/kms`, `luxon` (time zones),
`zod` (input validation for every callable), `adhan` (npm port of the same prayer-time algorithm,
for "after azan" rules on the server).

**Rules for every function**
1. Validate every callable input with `zod`. On a bad input, throw `HttpsError('invalid-argument')`.
2. Callables set `enforceAppCheck: true` (except `ensureUserProfile` during the first rollout).
3. Triggers **must be idempotent**. Firestore triggers can run more than once — write with
   deterministic ids, use transactions, never "increment" without an idempotency key.
4. Triggers must **not loop**: a function that writes to the same document it listens to must check
   what changed and exit early.
5. Log with `logger.info({ fn, uid, … })`. **Never log CNIC, tokens or phone numbers.**
6. Errors for the client use `HttpsError` codes: `unauthenticated`, `permission-denied`,
   `not-found`, `already-exists`, `failed-precondition`, `resource-exhausted`, `invalid-argument`.
   The app maps these codes to localized messages.

## 2. Function catalog

### 2.1 Auth & account
| Name | Type | What it does |
|------|------|--------------|
| `onUserCreated` | `identity`/Auth trigger (v1 `auth.user().onCreate`, allowed next to v2) | Creates `users/{uid}` with defaults if missing: `modes: {individual:true}`, `onboardedModes:false`, `prayerSettings` = PK defaults (D-095), `trackingSince` = today (PKT) |
| `ensureUserProfile` | callable | Same as above (idempotent) + updates `name/locale/timezone/lastSeenAt`, copies `email/phone` from the token. Returns `{pendingTeacherInvite?: {orgId, orgName}, pendingMosqueAdminInvite?: {mosqueId, name}}`, found **only** when `email_verified == true` |
| `deleteAccount` | callable, 540 s, 1 GiB | 05 §8.2 |

### 2.2 Prayer statistics
| Name | Type | What it does |
|------|------|--------------|
| `onSelfPrayerWritten` | `onDocumentWritten('users/{uid}/prayers/{logId}')` | `recomputeDay(subject, dateKey)` |
| `onChildPrayerWritten` | `onDocumentWritten('children/{id}/prayers/{logId}')` | same |
| `onStudentPrayerWritten` | `onDocumentWritten('students/{id}/prayers/{logId}')` | same |
| `nightlyStreakRollover` | `onSchedule('every day 00:30', timeZone PKT)` | For subjects whose streak had a perfect "yesterday-1" but nothing for yesterday, reset `current` to 0. Only touches subjects active in the last 3 days (query `stats/streak.lastPerfectDateKey`) |

`recomputeDay(subject, dateKey)`:
```ts
// 1. Read all logs for that dateKey (≤ 13 docs: 5 fard + nawafil + qaza)
const logs = await db.collection(`${subject}/prayers`).where('dateKey', '==', dateKey).get();
// 2. Build the summary and write dailySummaries/{dateKey}  (set, not merge → idempotent)
// 3. Streak: in a transaction, read stats/streak and the summaries for dateKey-1 and dateKey+1 as needed
//    - If the day became perfect: walk back from dateKey through perfect summaries (max 400 days,
//      stop at the first gap) to compute `current` when dateKey is the latest perfect day;
//      longest = max(longest, current)
//    - If a day stopped being perfect: recompute current from the latest perfect day backwards
//    Because edits are limited to 8 days back (D-075), this is cheap in practice.
// 4. Badges: add ids whose threshold is reached (first_step:1, week_warrior:7, month_light:30,
//    nawafil_nur: nawafilTotal ≥ 10). Badges are never removed once earned.
// 5. Qaza: if a qaza log changed OR a fard log changed, recompute stats/qaza (09 §4.3)
```

### 2.3 Family
| Name | Type | What it does |
|------|------|--------------|
| `onChildCreated` / `onChildDeleted` | Firestore triggers on `children/{id}` | Keep `users/{g}.modes.parent.childCount` right for each guardian. Write `children/{id}.guardians = {uid: name}` for display |
| `createGuardianCode` | callable `{childId}` | Caller must be a guardian; child has < 4 guardians; max 5 active codes per child. Creates `linkCodes/{code}` (`kind:'guardian'`, expires in 48 h). Returns `{code, expiresAt}` |
| `redeemGuardianCode` | callable `{code}` | Transaction: code exists, not expired, `usesLeft > 0`, caller not already a guardian, child < 4 guardians → `arrayUnion(caller)` into `guardianUids`, `usesLeft = 0`, bump `childCount`. Rate limit: 10 failed attempts per uid per hour → `resource-exhausted` |
| `removeGuardian` | callable `{childId, guardianUid}` | A guardian may remove **themself**, or remove another guardian **only if they created the child** (`createdBy`). The last guardian can't leave (they must delete the child) |
| `removeChild` | callable `{childId}` | Only `createdBy` or the only guardian. Deletes the child recursively, unlinks students (`students.linkedChildIds`/`guardianUids` cleanup), updates counts |

### 2.4 Organization
| Name | Type | What it does |
|------|------|--------------|
| `createOrganization` | callable `{name, type, city, address}` | Caller has no `modes.org`. Creates the org with `adminUid = caller`, sets `modes.org = {orgId, role:'admin', orgName}` |
| `acceptTeacherInvite` | callable `{orgId}` | Token `email_verified` true; invite `organizations/{orgId}/invites/{emailLower(token.email)}` is `pending`; caller has no `modes.org` (D-043). Transaction: invite → claimed, create `teachers/{uid}`, set `modes.org = {orgId, role:'teacher'}`, `counts.teachers++` |
| `declineTeacherInvite` | callable | invite → `declined` |
| `removeTeacher` | callable `{orgId, teacherUid}` | Admin only. Deletes the teacher doc, sets `modes.org = null` for that user, reassigns their classes' `teacherUid` to the admin (and their students' `teacherUid`) so nothing is orphaned. Sends the teacher a push |
| `leaveOrganization` | callable | Teacher leaves (same clean-up as above) |
| `transferOrganization` | callable `{orgId, newAdminUid}` | Admin only; the new admin must be a teacher of the org. Swaps roles |
| `deleteOrganization` | callable `{orgId, confirmName}` | Admin only; `confirmName` must equal the org name. Cascade delete |
| `onClassWritten` | trigger `organizations/{orgId}/classes/{classId}` | If `teacherUid` changed → batch update all students of that class. Keep `counts.classes` |
| `onStudentWritten` | trigger `students/{sid}` | Keep `classes.studentCount` and `counts.students`; if `classId` changed, copy the new class's `teacherUid` |
| `createStudentLinkCode` | callable `{studentId}` | Caller = teacher of the student or org admin; `org.allowParentLinking == true`. Code valid **30 days**, one use; a student may have ≤ 4 guardians. Returns `{code, expiresAt}` |
| `redeemStudentLinkCode` | callable `{code, childId}` | Caller is a guardian of `childId`. Transaction: add caller **and all of that child's guardians** to `students.guardianUids`, add `studentId` to `children.linkedStudentIds`, `childId` to `students.linkedChildIds`. Returns `{orgName, className, studentName}` |
| `unlinkStudent` | callable `{studentId, childId}` | Guardian of the child **or** teacher/admin. Removes the link both ways |
| `removeStudent` | callable `{studentId}` | Teacher/admin. Sets `active=false` by default; `hardDelete:true` (admin only) deletes recursively |
| `requestOrgVerification` | callable `{orgId, note, contactPhone}` | Admin. `verification.status = 'requested'` |

### 2.5 Mosques
| Name | Type | What it does |
|------|------|--------------|
| `submitMosqueRequest` | callable | 10 §3.3. Validates, encrypts CNIC (KMS), writes `mosqueRequests` + `mosqueRequestsPrivate`, finds duplicates. Rate limit: 3 open requests per user |
| `respondToNeedsInfo` | callable `{requestId, message, extraProofPaths}` | Requester replies; status → `pending` |
| `reviewMosqueRequest` | callable (platform) `{requestId, decision: 'approve'\|'reject'\|'needsInfo', note, edits?}` | **approve/new**: create `mosques/{id}` (`listed:true`, `adminUids:[requester]`, `primaryAdminUid`, geohash, keywords, default Jama'at if given); add to the requester's `modes.masjidAdminOf`; push to requester. **approve/claimAdmin**: add requester to `adminUids` if < 3 (else `failed-precondition`). **reject**: status + note; schedule CNIC purge in 30 days. Every decision writes `platformAudit` |
| `onMosqueWritten` | `onDocumentUpdated('mosques/{id}')` | If `jamaatVersion` changed: (1) **validate deeply** (upcoming dates in the future and ≤ 180 days ahead, valid rules, Jumu'ah times); if invalid, **revert** to the `before` data and push to the admin "Publish failed"; (2) write `jamaatHistory`; (3) build a diff text and send FCM to topic `mosque_{id}` (§3). Ignore writes where only counters changed |
| `applyDueJamaatChanges` | `onSchedule('every day 00:05', PKT)` | For mosques where `upcoming[0].effectiveFrom <= today`: merge into `jamaat`/`jumuah`, remove from `upcoming`, write history (`kind:'applyScheduled'`). **Does not** bump `jamaatVersion` (so no second push) |
| `remindTomorrowChanges` | `onSchedule('every day 20:00', PKT)` | For mosques with a change effective **tomorrow**: push to `mosque_{id}`: "Tomorrow Fajr jama'at changes to 05:30" |
| `inviteMosqueAdmin` | callable `{mosqueId, email}` | Primary admin; `adminUids.length + pending invites < 3` |
| `acceptMosqueAdminInvite` | callable `{mosqueId}` | Verified email matches; add to `adminUids`, `modes.masjidAdminOf` |
| `removeMosqueAdmin` | callable `{mosqueId, uid}` | Primary admin removes others; anyone may remove themself; platform can remove anyone. If the primary admin leaves, the oldest remaining admin becomes primary; if none, `needsAdmin = true` |
| `onReportCreated` | `onDocumentCreated('mosques/{id}/reports/{rid}')` | `openReportCount++`; push to each admin's devices "New report for {mosque}" |
| `onReportUpdated` | trigger | `openReportCount--` when it leaves `open` |
| `escalateReports` | `onSchedule('every day 09:00', PKT)` | Reports `open` for > 7 days → `escalatedAt = now` (visible in the dashboard queue) |
| `onUserMosquesChanged` | `onDocumentUpdated('users/{uid}')` | When `mosques.savedIds`/`primaryId` changes, adjust `followerCount` (+1/−1 per diff). Exit early if `mosques` didn't change |

### 2.6 Platform (dashboard only — every one checks `platformRole`)
| Name | What it does |
|------|--------------|
| `setPlatformRole` | superAdmin only: `setCustomUserClaims(uid, {platformRole})`; audit |
| `revealCnic` | reviewer/superAdmin: decrypts and returns the CNIC for **one** request; writes `platformAudit` with the actor; limit 50/day per actor |
| `sendAnnouncement` | superAdmin: writes `announcements/{id}`, sends to topics `announcements_en` / `announcements_ur` |
| `verifyOrganization` | reviewer: sets `verification.status` to `verified`/`rejected` + note, pushes to the org admin |
| `setMosqueListed` | reviewer: suspend or restore a mosque |
| `assignMosqueAdmin` | reviewer: add or replace admins (e.g. `needsAdmin` mosques) |
| `editMosqueInfo` | reviewer: change name/location/etc. (and approves `editInfo` requests) |

### 2.7 Push & maintenance
| Name | What it does |
|------|--------------|
| `subscribeWebTopics` | callable `{token, topics[]}`: web can't subscribe from the client. Only allows `mosque_*` for mosques in the user's `savedIds` and `announcements_*` |
| `cleanupTokens` | Weekly: delete `devices` with `lastSeenAt` > 60 days. `fcm.ts` also deletes a token right away when a send returns `messaging/registration-token-not-registered` |
| `purgeExpiredCodes` | Daily: delete expired `linkCodes` |
| `purgeCnic` | Daily: delete `mosqueRequestsPrivate` docs past `purgeAfter` (rejected + 30 days; withdrawn + 7 days) |
| `scheduledBackup` | Daily 03:00 PKT: Firestore export to `gs://jaiza-namaz-backups` (keep 30 days via a lifecycle rule) |

## 3. FCM message formats

```ts
// Jama'at change (topic mosque_{id})
{
  topic: `mosque_${id}`,
  notification: { title: 'Jama\'at time updated', body: 'Masjid Al-Noor · Fajr 05:15 → 05:30 (from Mon 3 Nov)' },
  data: { kind: 'jamaatChanged', mosqueId: id, version: String(v), route: `/app/mosques/${id}` },
  android: { notification: { channelId: 'jamaat_changes' }, priority: 'high' },
  apns: { payload: { aps: { sound: 'default' } } },
}
```
- **Language**: topic messages go to everyone, so the body is sent in **both** languages in `data`
  (`body_en`, `body_ur`), and the visible `notification` uses English + Urdu on two lines:
  `"Fajr 05:15 → 05:30\nفجر ۵:۱۵ ← ۵:۳۰"`. *(Alternative: separate topics `mosque_{id}_en` / `_ur`.
  Not chosen, to halve subscriptions.)*
- The app's background handler also **refreshes the local Jama'at reminders** for that mosque when
  it gets `kind: 'jamaatChanged'` (13 §2.5).

## 4. Skeletons

### 4.1 A callable
```ts
// src/family/redeemGuardianCode.ts
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db, FieldValue } from '../lib/admin';

const Input = z.object({ code: z.string().regex(/^[A-Z2-9]{6}$/) });

export const redeemGuardianCode = onCall({ enforceAppCheck: true }, async (req) => {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Sign in first');
  const { code } = Input.parse({ code: String(req.data?.code ?? '').replace('-', '').toUpperCase() });
  const uid = req.auth.uid;

  return db.runTransaction(async (tx) => {
    const codeRef = db.doc(`linkCodes/${code}`);
    const c = (await tx.get(codeRef)).data();
    if (!c || c.kind !== 'guardian') throw new HttpsError('not-found', 'code-invalid');
    if (c.expiresAt.toMillis() < Date.now() || c.usesLeft < 1) throw new HttpsError('failed-precondition', 'code-expired');

    const childRef = db.doc(`children/${c.targetId}`);
    const child = (await tx.get(childRef)).data();
    if (!child) throw new HttpsError('not-found', 'child-missing');
    if (child.guardianUids.includes(uid)) throw new HttpsError('already-exists', 'already-guardian');
    if (child.guardianUids.length >= 4) throw new HttpsError('failed-precondition', 'too-many-guardians');

    tx.update(childRef, { guardianUids: FieldValue.arrayUnion(uid), updatedAt: FieldValue.serverTimestamp() });
    tx.update(codeRef, { usesLeft: 0, usedBy: uid, usedAt: FieldValue.serverTimestamp() });
    tx.set(db.doc(`users/${uid}`), { modes: { parent: { childCount: FieldValue.increment(1) } } }, { merge: true });
    return { childId: c.targetId, childName: child.name };
  });
});
```
*(`childCount` via increment is safe here because the transaction runs once per successful redeem.
The `onChildCreated/Deleted` triggers recompute the absolute count as a safety net.)*

### 4.2 Flutter side of a callable
```dart
final res = await ref.read(functionsProvider)
    .httpsCallable('redeemGuardianCode')
    .call<Map<String, dynamic>>({'code': code});
// FirebaseFunctionsException e → e.code ('not-found', …) and e.message ('code-invalid') → ErrorMapper → l10n
```

## 5. Local development

```bash
cd functions && npm ci && npm run build
firebase emulators:start --only auth,firestore,functions,storage --import=./emulator-data --export-on-exit
```
Run the app with `flutter run --dart-define=USE_EMULATORS=true`.
Seed data: `npm run seed` (script creates test users, a demo org, 5 demo mosques around Lahore/Karachi).

## 6. Deploy

```bash
npm --prefix functions run lint && npm --prefix functions test
firebase deploy --only functions            # or --only functions:mosques-onMosqueWritten
```
- CI (GitHub Actions) deploys `main` after tests pass, using a service account with the least roles:
  *Cloud Functions Admin, Service Account User, Firebase Rules Admin, Cloud Datastore Index Admin*.
- **Secrets** (`defineSecret`): `CNIC_HMAC_KEY`, `APPLE_PRIVATE_KEY`, `APPLE_KEY_ID`, `APPLE_TEAM_ID`.
  The KMS key isn't a secret — access is by IAM (15 §8).
