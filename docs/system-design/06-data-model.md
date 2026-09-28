# 06 — Data Model (Firestore + Storage)

Legend for the **W** column (who writes): **C** = client (checked by rules), **F** = Cloud Function
only, **D** = admin dashboard via callable (so really F).
Every document has `createdAt` and `updatedAt` (server timestamps) unless noted.

## 1. Collection map

```
users/{uid}
  ├── prayers/{logId}             self prayer logs
  ├── dailySummaries/{dateKey}    F
  ├── stats/streak                F
  ├── stats/qaza                  F   (Qaza counters)
  ├── devices/{deviceId}          FCM tokens
  └── announcementsRead/{id}      optional read receipts
children/{childId}
  ├── prayers/{logId}
  ├── dailySummaries/{dateKey}    F
  ├── stats/streak  stats/qaza    F
organizations/{orgId}
  ├── invites/{emailLower}
  ├── teachers/{teacherUid}       F
  └── classes/{classId}
students/{studentId}
  ├── prayers/{logId}
  ├── dailySummaries/{dateKey}    F
  └── stats/streak                F
mosques/{mosqueId}                public (approved only)
  ├── jamaatHistory/{id}          F
  ├── reports/{reportId}
  └── adminInvites/{emailLower}
mosqueRequests/{requestId}
mosqueRequestsPrivate/{requestId} F only, no client access (CNIC ciphertext)
linkCodes/{code}                  F only
announcements/{id}                D
feedback/{id}
platformAudit/{id}                F
deletionLog/{id}                  F
config/public                     D (small public settings; most config is Remote Config)
```

**Old collections to remove after migration (18 §3):** top-level `prayers`, `streaks`,
`users/{uid}/children`, `organizations/{id}/classes/{id}/students`.

---

## 2. Documents

### 2.1 `users/{uid}`
| Field | Type | W | Notes |
|-------|------|---|-------|
| `uid` | string | F | = doc id |
| `name` | string | C | 2–50 chars |
| `email` | string? | F | from Auth; lowercased copy `emailLower` |
| `phone` | string? | F | from Auth (phone provider) |
| `photoUrl` | string? | C | Storage download URL (17 §1) |
| `city` | string? | C | |
| `locale` | `'en' \| 'ur'` | C | |
| `timezone` | string | C | IANA from `flutter_timezone`, e.g. `Asia/Karachi`. Used by Functions for dateKeys |
| `modes` | map | **F** | see 05 §4.1 |
| `lastMode` | string | C | `individual \| parent \| organization \| masjidAdmin` |
| `onboardedModes` | bool | C | |
| `nawafilEnabled` | bool | C | as today |
| `prayerSettings` | map | C | see below |
| `qazaPlan` | map | C | see below |
| `mosques` | map | C | see below (D-073) |
| `notificationPrefs` | map | C | announcements on/off, change alerts on/off |
| `trackingSince` | string dateKey | F | first day of tracking (replaces device-only `jz_tracking_since_v1`) |
| `deletion` | map? | F | `{status, startedAt}` during deletion |
| `lastSeenAt` | timestamp | F | |

`prayerSettings` (keeps today's keys, `PrayerSettingsParsed`):
```
{ calcMethod: 'karachi', madhab: 'hanafi', useGps: true,
  manualLat, manualLon, manualLabel, manualCity,
  notificationsEnabled: true,
  perPrayerNotifications: {fajr: true, …},      // end reminders
  startPrayerNotifications: {fajr: true, …},    // start reminders
  customEndMessages: {fajr: '…'},
  endReminderMinutes: 10 }
```
`qazaPlan` (keeps today's `QazaPlanParsed`, adds the reminder):
```
{ perPrayer: { fajr: {years, months, days}, … },   // estimate since puberty
  dailyGoal: 5,
  reminder: { enabled: true, time: '21:00' } }     // D-063
```
`mosques`:
```
{ primaryId: 'm_abc' | null,
  savedIds: ['m_abc', 'm_def'],                     // max 20
  alerts: { enabled: true, minutesBefore: 10, mosqueIds: ['m_abc'] },
  changeAlerts: true }                              // FCM topic subscriptions
```
Legacy fields `role`, `orgId`, `orgMemberRole`, `qazaBacklog*`, `qazaDailyTarget` are **read** once
for migration and then removed.

### 2.2 Prayer log — `{subject}/prayers/{logId}`
Same shape for `users/{uid}/prayers`, `children/{id}/prayers`, `students/{id}/prayers`.

`logId = '{dateKey}_{prayerName}_{type}'` (e.g. `2026-09-28_asr_fard`) — deterministic, so marking
is an idempotent `set()` (offline-safe, no duplicates). **Qaza logs** use
`'{dateKey}_{prayerName}_qaza'` with a `count` field (many make-ups per day, see 09 §4).

| Field | Type | Notes |
|-------|------|-------|
| `dateKey` | string | `YYYY-MM-DD` in the subject's local calendar |
| `prayerName` | string | `fajr … isha`, `witr`, `tahajjud`, `ishraq`, `chasht`, `awwabin`, `rawatib`, `taraweeh` |
| `type` | `fard \| nawafil \| qaza` | |
| `status` | `completed \| missed` | Fard/Nawafil only. "Clear" = delete the doc |
| `count` | int | Qaza only (≥ 0) |
| `inJamaat` | bool? | Fard only, optional "prayed with Jama'at" (for future stats) |
| `markedBy` | string | uid of whoever wrote it (self, guardian, teacher) |
| `source` | `app \| widget \| teacher \| guardian` | |
| `markedAt` | timestamp | server time |
| `dateTime` | timestamp | kept for compatibility with current queries (UTC of the prayer window start) |

### 2.3 `{subject}/dailySummaries/{dateKey}` (F)
```
{ dateKey, fardDone: 0..5, fardMissed: 0..5, fardUnmarked: 0..5,
  fard: { fajr: 'completed'|'missed'|null, … },
  nawafilDone: n, qazaDone: n, perfect: bool, updatedAt }
```
Records/calendar screens read one month of these (≤ 31 small docs) instead of every log.

### 2.4 `{subject}/stats/streak` (F)
`{ current, longest, lastPerfectDateKey, badges: ['first_step', …], nawafilTotal, updatedAt }`

### 2.5 `{subject}/stats/qaza` (F)
`{ perPrayer: { fajr: { estimate, trackedMissed, completed, remaining }, … }, totalRemaining, updatedAt }`

### 2.6 `users/{uid}/devices/{deviceId}`
`deviceId` = a random id saved on the device (per install).
`{ token, platform: 'android'|'ios'|'web', locale, appVersion, lastSeenAt }`

### 2.7 `children/{childId}`
| Field | Type | W | Notes |
|-------|------|---|-------|
| `name` | string | C | |
| `birthYear` | int? | C | UI asks age; stored as `currentYear - age` (D-032) |
| `gender` | `boy \| girl`? | C | |
| `guardianUids` | string[] | **F** after create | max 4. On create, client sets exactly `[auth.uid]` |
| `createdBy` | string | C (create) | |
| `trackingSince` | dateKey | C (create) | |
| `linkedStudentIds` | string[] | F | madrasa links (11 §5) |
| `qazaPlan` | map | C | same shape as user |
| `linkedUid` | string? | F | future: child's own login (D-030) |
| `guardians` | map uid → name | F | for "Marked by …" and the guardians list |

### 2.8 `organizations/{orgId}`
| Field | Type | W | Notes |
|-------|------|---|-------|
| `name`, `nameLower` | string | C (admin) | |
| `type` | `madrasa \| school \| academy \| other` | C | |
| `city`, `address` | string | C | |
| `adminUid` | string | F | set by `createOrganization` callable |
| `verification` | map | F/D | `{status: 'none'\|'requested'\|'verified'\|'rejected', requestedAt, decidedAt, note}` |
| `allowParentLinking` | bool | C (admin) | default true |
| `counts` | map | F | `{teachers, classes, students}` |

`organizations/{orgId}/invites/{emailLower}`: `{email, role:'teacher', status:'pending'|'claimed'|'revoked', invitedAt, invitedBy, claimedByUid?, claimedAt?}` — create/revoke by admin (C), claim by **F**.

`organizations/{orgId}/teachers/{uid}` (F): `{uid, name, email, joinedAt}`.

`organizations/{orgId}/classes/{classId}`:
`{name, section?, teacherUid, studentCount (F), createdAt}` — section is D-045.

### 2.9 `students/{studentId}` (top level, D-046)
| Field | Type | W | Notes |
|-------|------|---|-------|
| `orgId`, `classId` | string | C (teacher/admin) | |
| `teacherUid` | string | C | copy of the class's teacher (for simple rules). Updated by F when a class changes teacher |
| `name` | string | C | |
| `fatherName`, `rollNo` | string? | C | optional; shown on the report card |
| `gender` | `boy \| girl`? | C | |
| `active` | bool | C | false = left madrasa (kept for reports) |
| `guardianUids` | string[] | **F** | parents who linked with a code |
| `linkedChildIds` | string[] | F | |
| `orgName`, `className` | string | F | copies for linked parents (they can't read the org/class docs) |

### 2.10 `mosques/{mosqueId}` (public, approved only)
| Field | Type | W | Notes |
|-------|------|---|-------|
| `name`, `nameUr?` | string | F/D (edits by admin go through review) | |
| `searchKeywords` | string[] | F | lowercased prefixes of name words + city (10 §8) |
| `address`, `area`, `city`, `province` | string | F/D | |
| `country` | `'PK'` | F | D-059 |
| `timezone` | `'Asia/Karachi'` | F | |
| `location` | GeoPoint | F/D | |
| `geo` | map | F | `{geohash, geopoint}` — format used by `geoflutterfire_plus` |
| `fiqh` | `hanafi \| ahleHadith \| shia \| other` | F/D | display + defaults |
| `calcMethod`, `madhab` | string | C (admin) | used for "after azan" rules |
| `phone`, `photoUrl` | string? | C (admin) | |
| `listed` | bool | D | false = hidden (suspended) |
| `adminUids` | string[] | F | max 3 (D-053) |
| `primaryAdminUid` | string | F | |
| `needsAdmin` | bool | F | |
| `jamaat` | map | C (admin) | current rules, see below |
| `jumuah` | list | C (admin) | up to 3 |
| `upcoming` | list | C (admin) | scheduled changes, max 10 |
| `jamaatVersion` | int | C (admin) | +1 on each publish (rules check it) |
| `jamaatUpdatedAt`, `jamaatUpdatedBy` | | C (admin) | |
| `followerCount` | int | F | |
| `openReportCount` | int | F | |
| `verifiedAt`, `requestId` | | F | |

```
jamaat: {
  fajr:    { type: 'fixed', time: '05:15' },
  zuhr:    { type: 'fixed', time: '13:30' },
  asr:     { type: 'fixed', time: '16:45' },
  maghrib: { type: 'afterAzan', offsetMinutes: 5 },
  isha:    { type: 'fixed', time: '20:30' } }
jumuah: [ { time: '13:15', label: 'Urdu bayan' }, { time: '14:00' } ]
upcoming: [ { id: 'u1', effectiveFrom: '2026-11-03',
              jamaat: { fajr: { type: 'fixed', time: '05:30' } },   // only changed prayers
              jumuah: null,                                         // null = unchanged
              createdBy, createdAt } ]
```

`mosques/{id}/jamaatHistory/{autoId}` (F): `{before, after, publishedBy, publishedAt, kind: 'publish'|'applyScheduled'}`.

`mosques/{id}/reports/{uid}_{dateKey}`: `{reporterUid, reporterName, prayer?, message (≤ 300), status: 'open'|'resolved'|'dismissed', createdAt, resolvedBy?, resolvedAt?, escalatedAt?}` — doc id makes it **one report per user per mosque per day**.

`mosques/{id}/adminInvites/{emailLower}`: `{email, invitedBy, status, createdAt}` — primary admin (C), claimed by F.

### 2.11 `mosqueRequests/{requestId}`
| Field | Notes |
|-------|-------|
| `kind` | `new \| claimAdmin \| editInfo` |
| `mosqueId` | for `claimAdmin` / `editInfo` |
| `requesterUid`, `requesterName`, `requesterPhone`, `requesterRoleAtMosque` (`imam \| khateeb \| muezzin \| committee \| other`) | |
| `proposed` | map: name, address, area, city, province, location {lat,lng}, fiqh, phone, jamaat? |
| `cnicLast4` | string (e.g. `'4567'`) |
| `proofPaths`, `photoPaths` | Storage paths (private) |
| `status` | `pending \| needsInfo \| approved \| rejected \| withdrawn` |
| `reviewerUid`, `reviewNote`, `decidedAt` | D |
| `possibleDuplicateIds` | F — nearby mosques with a similar name |

`mosqueRequestsPrivate/{requestId}` (F, **no client access**):
`{ cnicCiphertext (base64), cnicKeyVersion, cnicHmac (for duplicate check), createdAt, purgeAfter }`.

### 2.12 `linkCodes/{code}` (F only)
`{ kind: 'guardian' | 'student', targetId (childId | studentId), orgId?, createdBy, createdAt,
   expiresAt, usesLeft: 1, usedBy?: uid, usedAt? }`
Code format: 6 chars from `ABCDEFGHJKMNPQRSTUVWXYZ23456789` (no 0/O/1/I/L), shown as `K7P-3QX`.

### 2.13 Others
- `announcements/{id}` (D): `{title: {en, ur}, body: {en, ur}, sentAt, sentBy, topic, deepLink?}`
- `feedback/{id}` (C create only): `{uid?, name, email?, category: 'bug'|'idea'|'mosque'|'other', message, appVersion, platform, status (D), createdAt}`
- `platformAudit/{id}` (F): `{actorUid, action ('revealCnic'|'approveMosque'|…), targetId, at, ip?}`
- `deletionLog/{id}` (F): `{at, counts}` — no personal data.

## 3. Storage layout (`storage.rules`, 07 §3)

```
users/{uid}/avatar.jpg                              public-read (via token URL), owner write, ≤ 1 MB, image/*
mosques/{mosqueId}/photo.jpg                        public-read, admin write via F
mosqueRequests/{uid}/{requestId}/proof_{n}.{jpg|pdf}  requester write-once; read: requester + platform admins; ≤ 5 MB
mosqueRequests/{uid}/{requestId}/photo_{n}.jpg      same
reports/{orgId}/…                                   (not used — PDFs are generated and shared on device)
```

## 4. Indexes (`firestore.indexes.json`)

| Collection (scope) | Fields | Used by |
|--------------------|--------|---------|
| `prayers` (collection) | `type` ASC, `dateKey` DESC | per-subject history by type |
| `prayers` (collection) | `dateKey` ASC, `type` ASC | day range queries |
| `dailySummaries` (collection) | `dateKey` ASC | month ranges (single-field, auto) |
| `students` | `classId` ASC, `active` ASC, `name` ASC | class roster |
| `students` | `orgId` ASC, `active` ASC | org counts / admin views |
| `children` | `guardianUids` ARRAY_CONTAINS, `createdAt` ASC | parent's children list |
| `mosques` | `listed` ASC, `searchKeywords` ARRAY_CONTAINS, `name` ASC | name search |
| `mosques` | `listed` ASC, `city` ASC, `name` ASC | city filter |
| `mosques` | `listed` ASC, `geo.geohash` ASC | nearby |
| `mosqueRequests` | `status` ASC, `createdAt` ASC | dashboard queue |
| `mosqueRequests` | `requesterUid` ASC, `createdAt` DESC | "my requests" |
| `reports` (collection group) | `status` ASC, `createdAt` ASC | escalation job |
| `invites` (collection group) | `email` ASC, `status` ASC | `ensureUserProfile` (server side) |
| `feedback` | `status` ASC, `createdAt` DESC | dashboard |

Deploy with `firebase deploy --only firestore:indexes`. If a query fails with "requires an index",
the error has a link — add that index to the JSON file (don't only click the link).

## 5. Size & cost notes
- Largest documents: `mosques/{id}` (< 10 KB) and `users/{uid}` (< 20 KB). Well under the 1 MiB limit.
- A child with 1 year of Fard = 1,825 log docs — fine, because screens read daily summaries, not raw logs.
- Qaza backlogs of thousands are **counters**, not thousands of docs (09 §4).
