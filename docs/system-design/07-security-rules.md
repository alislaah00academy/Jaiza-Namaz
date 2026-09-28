# 07 — Security Rules

## 1. Problems in the current `firestore.rules` (fix before any public release)

| # | Rule today | Attack | Fixed by |
|---|-----------|--------|----------|
| 1 | `invites`: create/update allowed if `request.resource.data.claimedByUid == request.auth.uid` | **Any** signed-in user can mark **any** org's invite as claimed by themselves | Claim moves to callable `acceptTeacherInvite` (checks the verified email). Clients can't write `status`/`claimedByUid` |
| 2 | `teachers/{teacherUid}`: create allowed if `auth.uid == teacherUid` | Anyone can add themselves as a teacher of **any** org, then create classes there (`classes` create only checks `teacherUid == auth.uid`) | `teachers` written only by Functions |
| 3 | `streaks/{userId}`: read/write for **any** signed-in user | Anyone can read or overwrite anyone's streak | Streaks move under the subject and are Function-only |
| 4 | `users/{uid}`: the owner can write every field | A user can set their own `role`/`orgId` | `modes` and other privileged fields are Function-only |
| 5 | `prayers` create allowed if `ownerUid == auth.uid` with **any** `userId` | An attacker can inject fake logs into **another user's** history (the victim's screens query by `userId`) | Logs move under subjects (D-072); rules check the parent document |
| 6 | `isOrgAdminFor()` does up to 3 `get()`s per document | Slow and costly. List queries on `prayers` by `userId` can't be proven by the rules and may be rejected | Subcollection design needs at most 1–2 `get()`s |
| 7 | `organizations` readable by any signed-in user | Low risk, but lists every org name and admin uid | Read limited to members; invitees get the org name from the callable |

## 2. New `firestore.rules`

> Deploy only after the migration (18 §3). Test every rule with the **Rules Unit Testing** library
> in `functions/test/rules/` against the emulator (§4).

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ---------- helpers ----------
    function signedIn() { return request.auth != null; }
    function me() { return request.auth.uid; }
    function isSelf(uid) { return signedIn() && me() == uid; }
    function isPlatform() {
      return signedIn() && request.auth.token.platformRole in ['superAdmin', 'reviewer'];
    }
    function data() { return request.resource.data; }
    function changed() { return request.resource.data.diff(resource.data).affectedKeys(); }
    function onlyChanges(keys) { return changed().hasOnly(keys); }

    function dayOf(dateKey) {
      let p = dateKey.split('-');
      return timestamp.date(int(p[0]), int(p[1]), int(p[2]));
    }
    // D-075: today and the previous 7 days (+1 day slack each side for time zones)
    function inEditWindow(dateKey) {
      return dateKey.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
        && dayOf(dateKey) > request.time - duration.value(9, 'd')
        && dayOf(dateKey) < request.time + duration.value(2, 'd');
    }
    function validLogId(logId) {
      return logId.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}_[a-zA-Z]+_(fard|nawafil|qaza)$');
    }
    function validLog(logId) {
      let parts = logId.split('_');
      return validLogId(logId)
        && data().dateKey == parts[0]
        && data().prayerName == parts[1]
        && data().type == parts[2]
        && data().markedBy == me()
        && inEditWindow(parts[0])
        && (
          (data().type in ['fard', 'nawafil'] && data().status in ['completed', 'missed'])
          || (data().type == 'qaza' && data().count is int && data().count >= 0 && data().count <= 50)
        );
    }
    function canDeleteLog(logId) { return validLogId(logId) && inEditWindow(logId.split('_')[0]); }

    function isGuardian(childId) {
      return signedIn() && me() in get(/databases/$(database)/documents/children/$(childId)).data.guardianUids;
    }
    function org(orgId) { return get(/databases/$(database)/documents/organizations/$(orgId)).data; }
    function isOrgAdmin(orgId) { return signedIn() && org(orgId).adminUid == me(); }
    function isOrgTeacher(orgId) {
      return signedIn() && exists(/databases/$(database)/documents/organizations/$(orgId)/teachers/$(me()));
    }
    function student(sid) { return get(/databases/$(database)/documents/students/$(sid)).data; }
    function canMarkStudent(sid) {
      let s = student(sid);
      return signedIn() && (s.teacherUid == me() || isOrgAdmin(s.orgId));
    }
    function canReadStudent(sid) {
      let s = student(sid);
      return signedIn() && (s.teacherUid == me() || me() in s.guardianUids || isOrgAdmin(s.orgId));
    }
    function mosque(id) { return get(/databases/$(database)/documents/mosques/$(id)).data; }
    function isMosqueAdmin(id) { return signedIn() && me() in mosque(id).adminUids; }

    // ---------- users ----------
    match /users/{uid} {
      allow read: if isSelf(uid) || isPlatform();
      allow create: if false;                       // ensureUserProfile / auth trigger
      allow update: if isSelf(uid)
        && !changed().hasAny(['uid', 'email', 'emailLower', 'phone', 'modes', 'trackingSince',
                              'deletion', 'lastSeenAt', 'createdAt'])
        && (!('mosques' in data()) || data().mosques.savedIds.size() <= 20);
      allow delete: if false;                       // deleteAccount only

      match /prayers/{logId} {
        allow read: if isSelf(uid);
        allow create, update: if isSelf(uid) && validLog(logId);
        allow delete: if isSelf(uid) && canDeleteLog(logId);
      }
      match /dailySummaries/{d} { allow read: if isSelf(uid); allow write: if false; }
      match /stats/{s}          { allow read: if isSelf(uid); allow write: if false; }
      match /devices/{deviceId} {
        allow read, delete: if isSelf(uid);
        allow create, update: if isSelf(uid)
          && data().keys().hasOnly(['token', 'platform', 'locale', 'appVersion', 'lastSeenAt'])
          && data().token is string && data().token.size() < 4096;
      }
    }

    // ---------- children (Parent mode) ----------
    match /children/{childId} {
      allow read: if signedIn() && me() in resource.data.guardianUids;
      allow create: if signedIn()
        && data().guardianUids == [me()]
        && data().createdBy == me()
        && data().name is string && data().name.size() > 0 && data().name.size() <= 50
        && !('linkedStudentIds' in data()) && !('linkedUid' in data());
      allow update: if signedIn() && me() in resource.data.guardianUids
        && onlyChanges(['name', 'birthYear', 'gender', 'qazaPlan', 'updatedAt']);
      allow delete: if false;                       // callable removeChild (handles co-guardians)

      match /prayers/{logId} {
        allow read: if isGuardian(childId);
        allow create, update: if isGuardian(childId) && validLog(logId);
        allow delete: if isGuardian(childId) && canDeleteLog(logId);
      }
      match /dailySummaries/{d} { allow read: if isGuardian(childId); allow write: if false; }
      match /stats/{s}          { allow read: if isGuardian(childId); allow write: if false; }
    }

    // ---------- organizations ----------
    match /organizations/{orgId} {
      allow read: if isOrgAdmin(orgId) || isOrgTeacher(orgId) || isPlatform();
      allow create: if false;                       // createOrganization callable
      allow update: if isOrgAdmin(orgId)
        && onlyChanges(['name', 'nameLower', 'type', 'city', 'address', 'allowParentLinking', 'updatedAt']);
      allow delete: if false;                       // deleteOrganization callable

      match /invites/{emailLower} {
        allow read: if isOrgAdmin(orgId);
        allow create: if isOrgAdmin(orgId)
          && emailLower == emailLower.lower()
          && data().email == emailLower
          && data().status == 'pending'
          && data().invitedBy == me();
        allow update: if isOrgAdmin(orgId) && onlyChanges(['status']) && data().status == 'revoked';
        allow delete: if isOrgAdmin(orgId) && resource.data.status != 'claimed';
      }
      match /teachers/{teacherUid} {
        allow read: if isOrgAdmin(orgId) || isSelf(teacherUid);
        allow write: if false;                      // acceptTeacherInvite / removeTeacher callables
      }
      match /classes/{classId} {
        allow read: if isOrgAdmin(orgId) || (isOrgTeacher(orgId) && resource.data.teacherUid == me());
        allow create: if (isOrgAdmin(orgId) || (isOrgTeacher(orgId) && data().teacherUid == me()))
          && data().name is string && data().name.size() <= 60
          && (data().teacherUid == me() || exists(/databases/$(database)/documents/organizations/$(orgId)/teachers/$(data().teacherUid)) || data().teacherUid == org(orgId).adminUid);
        allow update: if (isOrgAdmin(orgId) || resource.data.teacherUid == me())
          && onlyChanges(['name', 'section', 'teacherUid', 'updatedAt'])
          && (!('teacherUid' in changed()) || isOrgAdmin(orgId));   // only admin reassigns
        allow delete: if isOrgAdmin(orgId);
      }
    }

    // ---------- students ----------
    match /students/{sid} {
      allow read: if signedIn() && (
        resource.data.teacherUid == me()
        || me() in resource.data.guardianUids
        || isOrgAdmin(resource.data.orgId));
      allow create: if signedIn()
        && (isOrgAdmin(data().orgId)
            || (isOrgTeacher(data().orgId)
                && get(/databases/$(database)/documents/organizations/$(data().orgId)/classes/$(data().classId)).data.teacherUid == me()))
        && data().teacherUid == get(/databases/$(database)/documents/organizations/$(data().orgId)/classes/$(data().classId)).data.teacherUid
        && data().guardianUids == [] && !('linkedChildIds' in data());
      allow update: if signedIn()
        && (resource.data.teacherUid == me() || isOrgAdmin(resource.data.orgId))
        && onlyChanges(['name', 'fatherName', 'rollNo', 'gender', 'active', 'classId', 'teacherUid', 'updatedAt'])
        && data().orgId == resource.data.orgId;
      allow delete: if false;                       // removeStudent callable (cleans links + logs)

      match /prayers/{logId} {
        allow read: if canReadStudent(sid);
        allow create, update: if canMarkStudent(sid) && validLog(logId);
        allow delete: if canMarkStudent(sid) && canDeleteLog(logId);
      }
      match /dailySummaries/{d} { allow read: if canReadStudent(sid); allow write: if false; }
      match /stats/{s}          { allow read: if canReadStudent(sid); allow write: if false; }
    }

    // ---------- mosques ----------
    function validRule(r) {
      return (r.type == 'fixed' && r.time is string && r.time.matches('^([01][0-9]|2[0-3]):[0-5][0-9]$'))
          || (r.type == 'afterAzan' && r.offsetMinutes is int && r.offsetMinutes >= 0 && r.offsetMinutes <= 60);
    }
    function validJamaat(j) {
      return j.keys().hasOnly(['fajr', 'zuhr', 'asr', 'maghrib', 'isha'])
        && (!('fajr' in j) || validRule(j.fajr))
        && (!('zuhr' in j) || validRule(j.zuhr))
        && (!('asr' in j) || validRule(j.asr))
        && (!('maghrib' in j) || validRule(j.maghrib))
        && (!('isha' in j) || validRule(j.isha));
    }

    match /mosques/{mosqueId} {
      // Public (guests too) — queries MUST include where('listed', '==', true)
      allow read: if resource.data.listed == true || isPlatform()
        || (signedIn() && me() in resource.data.adminUids);
      allow create, delete: if false;
      allow update: if signedIn() && me() in resource.data.adminUids
        && onlyChanges(['jamaat', 'jumuah', 'upcoming', 'jamaatVersion', 'jamaatUpdatedAt',
                        'jamaatUpdatedBy', 'calcMethod', 'madhab', 'phone', 'updatedAt'])
        && data().jamaatVersion == resource.data.jamaatVersion + 1
        && data().jamaatUpdatedBy == me()
        && data().jamaatUpdatedAt == request.time
        && validJamaat(data().jamaat)
        && data().jumuah.size() <= 3
        && data().upcoming.size() <= 10;
      // Deep checks of `upcoming` entries happen again in onMosqueWritten (08); invalid publishes are reverted.

      match /jamaatHistory/{id} {
        allow read: if isMosqueAdmin(mosqueId) || isPlatform();
        allow write: if false;
      }
      match /reports/{reportId} {
        allow read: if isMosqueAdmin(mosqueId) || isPlatform()
          || (signedIn() && resource.data.reporterUid == me());
        allow create: if signedIn()
          && reportId.matches('^' + me() + '_[0-9]{4}-[0-9]{2}-[0-9]{2}$')   // one per user per day
          && inEditWindow(reportId.split('_')[1])
          && data().reporterUid == me()
          && data().status == 'open'
          && data().message is string && data().message.size() <= 300;
        allow update: if isMosqueAdmin(mosqueId)
          && onlyChanges(['status', 'resolvedBy', 'resolvedAt'])
          && data().status in ['resolved', 'dismissed'] && data().resolvedBy == me();
        allow delete: if false;
      }
      match /adminInvites/{emailLower} {
        allow read: if signedIn() && mosque(mosqueId).primaryAdminUid == me();
        allow create, delete: if signedIn() && mosque(mosqueId).primaryAdminUid == me();
        allow update: if false;
      }
    }

    // ---------- mosque requests ----------
    match /mosqueRequests/{requestId} {
      allow read: if isPlatform() || (signedIn() && resource.data.requesterUid == me());
      allow create: if false;                       // submitMosqueRequest callable (CNIC)
      allow update: if signedIn() && resource.data.requesterUid == me()
        && resource.data.status in ['pending', 'needsInfo']
        && onlyChanges(['status', 'updatedAt']) && data().status == 'withdrawn';
      allow delete: if false;
    }
    match /mosqueRequestsPrivate/{id} { allow read, write: if false; }   // Functions only
    match /linkCodes/{code}           { allow read, write: if false; }
    match /platformAudit/{id}         { allow read: if isPlatform() && request.auth.token.platformRole == 'superAdmin'; allow write: if false; }
    match /deletionLog/{id}           { allow read, write: if false; }

    // ---------- misc ----------
    match /announcements/{id} { allow read: if true; allow write: if false; }
    match /config/public      { allow read: if true; allow write: if false; }
    match /feedback/{id} {
      allow read, update: if isPlatform();
      allow create: if signedIn() && data().uid == me()
        && data().message is string && data().message.size() > 0 && data().message.size() <= 2000
        && data().status == 'new';
      allow delete: if false;
    }
  }
}
```

### 2.1 Notes for developers
- **Rules are not filters.** Every list query must match a rule on its own. For example:
  - Children list: `where('guardianUids', arrayContains: uid)` ✔
  - Students of a class (teacher): `where('classId', isEqualTo: id).where('teacherUid', isEqualTo: uid)` ✔
    (the org admin version is `where('orgId', isEqualTo: orgId)`, allowed through `isOrgAdmin`).
  - Mosques: always `where('listed', isEqualTo: true)` ✔
- Each `get()`/`exists()` costs one read and there is a limit of 10 per rule evaluation (20 for batched
  writes). The rules above use at most 3.
- The `validLog` window uses the **server** time. A phone with a wrong clock may fail — the app shows
  "Check your phone's date & time".

## 3. `storage.rules`

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function signedIn() { return request.auth != null; }
    function isPlatform() { return signedIn() && request.auth.token.platformRole in ['superAdmin', 'reviewer']; }
    function isImage() { return request.resource.contentType.matches('image/(jpeg|png|webp)'); }
    function isPdf()   { return request.resource.contentType == 'application/pdf'; }

    match /users/{uid}/avatar.jpg {
      allow read: if true;
      allow write: if signedIn() && request.auth.uid == uid && isImage() && request.resource.size < 1 * 1024 * 1024;
      allow delete: if signedIn() && request.auth.uid == uid;
    }

    match /mosques/{mosqueId}/{file} {
      allow read: if true;
      allow write: if signedIn()
        && request.auth.uid in firestore.get(/databases/(default)/documents/mosques/$(mosqueId)).data.adminUids
        && isImage() && request.resource.size < 2 * 1024 * 1024;
    }

    match /mosqueRequests/{uid}/{requestId}/{file} {
      allow read: if (signedIn() && request.auth.uid == uid) || isPlatform();
      allow create: if signedIn() && request.auth.uid == uid
        && (isImage() || isPdf()) && request.resource.size < 5 * 1024 * 1024;
      allow update, delete: if false;               // write-once evidence; Functions clean up
    }

    match /{allPaths=**} { allow read, write: if false; }
  }
}
```
> Note: a Storage **download URL** (with its token) can be opened by anyone who has it. **Never** create
> download URLs for proof documents. The dashboard reads them with the SDK (`getData()`) under
> platform-admin rules.

## 4. Testing rules (required in CI)

`functions/test/rules/*.test.ts` using `@firebase/rules-unit-testing` against the Firestore emulator.
At minimum, one **allow** and one **deny** test for each of these:

- A user can't write `users/{other}` or their own `modes`.
- A user can mark their own log only inside the 8-day window, with a valid id.
- A guardian can mark a child's log; a non-guardian can't read it.
- A second guardian added by the Function can read it; after removal they can't.
- A teacher can mark only their class's students; another teacher of the same org can't.
- A linked parent can **read** a student's logs but **not write** them.
- A stranger can't claim an invite or create a teacher doc.
- A guest (no auth) can read a listed mosque but not an unlisted one, and not `mosqueRequests`.
- A mosque admin can publish valid Jama'at with `jamaatVersion + 1`; an invalid time is rejected; a
  non-admin is rejected.
- Nobody can read `mosqueRequestsPrivate` or `linkCodes`.
