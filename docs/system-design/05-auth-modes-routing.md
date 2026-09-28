# 05 — Authentication, Guest, Modes, Routing, Account Deletion

## 1. Sign-in methods (D-020)

All methods go through `AuthRepository` (`features/auth/data/`). After **any** successful sign-in, the
app calls the same `onSignedIn(user)` step (§3).

| Method | Android / iOS | Web | Notes |
|--------|---------------|-----|-------|
| Email + password | `createUserWithEmailAndPassword`, `signInWithEmailAndPassword` | same | Send verification on sign-up (exists today) |
| Google | `google_sign_in` → `GoogleAuthProvider.credential(idToken)` → `signInWithCredential` | `signInWithPopup(GoogleAuthProvider())`; on mobile-sized browsers use `signInWithRedirect` | Android needs SHA-1 **and** SHA-256 in Firebase (debug + release + Play App Signing key) |
| Apple | `signInWithProvider(AppleAuthProvider()..addScope('email')..addScope('name'))` | `signInWithPopup(AppleAuthProvider())` | iOS: "Sign in with Apple" capability. Android/web: Apple **Services ID** + return URL (15 §4.4). Apple sends the name **only the first time** — save it to `users/{uid}.name` right away |
| Phone | `verifyPhoneNumber(phoneNumber, verificationCompleted, codeSent, …)` → `PhoneAuthProvider.credential(verificationId, smsCode)` | `signInWithPhoneNumber(phone, RecaptchaVerifier(...))` (invisible reCAPTCHA) | +92 only (D-023). iOS needs APNs set up for silent verification; otherwise it falls back to reCAPTCHA |

### 1.1 Account-exists-with-different-credential (D-022)
```
catch FirebaseAuthException(code: 'account-exists-with-different-credential', email, credential):
  1. Save the pending credential in memory.
  2. Show: "This email is already registered with <method>. Sign in with it to link Google."
     (Find the method by trying the one the user remembers. fetchSignInMethodsForEmail is
      unreliable when email-enumeration protection is on, so don't depend on it.)
  3. After they sign in with the old method: currentUser.linkWithCredential(pending).
```

### 1.2 Email verification (D-021)
`needsEmailVerification(user) = user.providerData.any(p => p.providerId == 'password') && !user.emailVerified`
- Google/Apple/phone users skip `/verify-email`.
- Keep the existing screen. Add: auto `reload()` every 5 s while visible, and a 60 s resend cooldown.

### 1.3 Password rules
Minimum 8 characters, at least one letter and one number. Also turn on the Firebase **password
policy** (Auth → Settings) with the same rule, so it is enforced on the server too.

## 2. Guest mode (D-017, D-018, D-019)

- `currentUidProvider == null` **and** onboarding done ⇒ **guest**.
- Guest data keys (SharedPreferences):
  `jz_guest_primary_mosque_v1`, `jz_guest_saved_mosques_v1`, `jz_guest_alerts_v1` (JSON: enabled,
  minutesBefore, mosqueIds), `jz_guest_location_v1` (JSON: useGps, lat, lng, label, city).
  (These replace the current `LocalKeys.primaryMosque` etc. The old keys are migrated on first run.)
- Guests read `mosques` (public, approved only) with App Check. Namaz times are calculated locally.
- **FCM for guests**: after the guest saves a mosque and grants notification permission, call
  `FirebaseMessaging.instance.subscribeToTopic('mosque_$id')` (Android/iOS). On web, topic
  subscription is not available in the client SDK, so guests on web **don't** get change alerts
  (signed-in web users do, through a callable — see 13 §2.4).

### 2.1 Guest → account merge (F-03)
In `onSignedIn` (§3), if `guestPrefs.hasData`:
```
userDoc = await users/{uid}.get()
if userDoc.mosques is empty:
   write users/{uid}.mosques = guestPrefs.mosques; users/{uid}.prayerSettings.location = guest location
   (topics are already subscribed; the Function syncs followerCount)
clear guest prefs
```

## 3. After sign-in / sign-up: `onSignedIn(user)`

Runs once per sign-in, in `AuthController`:
1. **Ensure the user doc** exists: call the callable `ensureUserProfile({name, locale, timezone})`.
   The Function creates `users/{uid}` with safe defaults if missing, or updates `lastSeenAt`. It also
   **finds pending teacher invites** for the verified email and returns them (so the client never runs
   the collection-group invite query itself any more).
   *(An `auth.user().onCreate` trigger also creates the doc, as a backup. Both are idempotent.)*
2. Merge guest data (§2.1).
3. Register the FCM token (13 §2.2).
4. Decide where to go:
   - If `users/{uid}.onboardedModes == false` (first login) ⇒ `/select-mode`.
     If `ensureUserProfile` returned a pending teacher invite, the Organization card shows
     "Invite from *X* — Accept".
   - Else ⇒ `/app` in the `activeModeProvider` mode.

## 4. Multi-mode accounts (D-010 … D-016)

### 4.1 Where mode data lives
```
users/{uid}.modes = {
  individual: true,                              // always true
  parent:     { childCount: 2 },                 // written by Function (child create/delete/join)
  org:        { orgId: 'o_123', role: 'admin' | 'teacher', orgName: 'Jamia …' } | null,   // Function only
  masjidAdminOf: ['m_1', 'm_2'],                 // Function only (max 5 mosques per person)
  platformRole: null                             // never here — platform roles are custom claims only
}
users/{uid}.lastMode = 'parent'
users/{uid}.onboardedModes = true                // set when the user leaves the mode chooser
```
- Clients **MUST NOT** write `modes` (rules block it, 07). Only Functions write it, as a side effect of
  the real action (adding a child, accepting an invite, approval).
- The **real source of truth** is still the membership document (`children/{id}.guardianUids`,
  `organizations/{id}/teachers/{uid}`, `mosques/{id}.adminUids`). `modes` is a **denormalized cache**
  so the app can build the mode switcher from one document. Rules always check the real document.

### 4.2 Legacy migration of `role`
| Old `users.role` | New `modes` |
|------------------|-------------|
| `null` / `individual` | `{individual: true}` |
| `parent` | `{individual: true, parent: {childCount: n}}` |
| `organization` + `orgMemberRole: admin` | `org: {orgId, role: 'admin'}` |
| `organization` + `orgMemberRole: teacher` | `org: {orgId, role: 'teacher'}` |
`lastMode` = the old role. Old fields `role`, `orgId`, `orgMemberRole` are deleted after migration
(18 §3).

### 4.3 Mode chooser screen (`/select-mode`)
- 4 cards (02 F-30). Individual is pre-selected.
- "Continue" ⇒ `users.onboardedModes = true` (client may write this one field), set active mode,
  go to `/app`.
- Card actions:
  - Parent → `/app/family/setup` (add first child, or "Join with a code").
  - Organization → `/app/org/setup` (create org) or accept invite (callable `acceptTeacherInvite`).
  - Masjid Admin → `/app/mosques/register` or the request status screen.

### 4.4 Mode switcher
- `ModeChip` in the app bar of every root tab. Shows the current mode icon + name.
- Bottom sheet: active modes (radio list) + "Set up another mode".
- On switch: `activeModeProvider.switchTo(mode)` ⇒ router goes to that mode's root tab.
- Notification behaviour per mode (13 §5): all local reminders for **all active modes** keep running
  no matter which mode is open (a parent still gets family reminders while in Individual mode).
  The switcher only changes **what is shown**.

## 5. Session & security details

- Firebase ID tokens refresh by themselves. When a Function changes custom claims (platform admins
  only), the dashboard calls `getIdToken(true)`.
- On sign-out: `FirebaseMessaging.deleteToken()` + delete `users/{uid}/devices/{deviceId}`,
  unsubscribe **user-only** topics, keep guest mosque topics only if the user chooses "Keep mosque
  alerts on this phone" (default yes), cancel user-specific local notifications (family, class, Qaza),
  clear `activeMode` cache, `FirebaseFirestore.instance.clearPersistence()` is **not** called (it
  would drop queued offline writes). Queued writes are protected by rules anyway.

## 6. Routing (`go_router`)

### 6.1 Route map
```
/splash  /onboarding  /welcome  /login  /signup  /phone  /reset-password  /verify-email
/select-mode
/guest/…                               # not separate; guest uses /app with a guest shell
/app                                   # ShellRoute; tabs depend on mode (02 F-31)
  /app/today                           # (renamed from /app/home; keep /app/home as an alias → /app/today)
  /app/prayers/fard  /app/prayers/nawafil
  /app/qaza  /app/qaza/estimate  /app/qaza/plan  /app/qaza/prayer/:name
  /app/records
  /app/mosques  /app/mosques/search  /app/mosques/:mosqueId  /app/mosques/:mosqueId/report
  /app/mosques/register  /app/mosques/claim/:mosqueId  /app/mosque-requests/:requestId
  /app/masjid/:mosqueId  /app/masjid/:mosqueId/timetable  /app/masjid/:mosqueId/admins  /app/masjid/:mosqueId/reports
  /app/family  /app/family/setup  /app/family/join  /app/family/:childId  /app/family/:childId/qaza
  /app/family/:childId/guardians  /app/family/:childId/madrasa  /app/family/reminders
  /app/org  /app/org/setup  /app/org/teachers  /app/org/teachers/:teacherUid  /app/org/verify
  /app/org/class/:classId  /app/org/class/:classId/mark  /app/org/class/:classId/add-students
  /app/org/class/:classId/report  /app/org/student/:studentId
  /app/more  /app/profile  /app/profile/sign-in-methods  /app/settings/notifications
  /app/announcements  /app/about  /app/academy-intro  /app/benefits  /app/contact  /app/donation
  /app/change-password  /app/delete-account
```

### 6.2 Redirect table (in order; first match wins)
`redirect()` is a **pure function** of: location, `isSignedIn`, `needsEmailVerification`,
`appUser` (loaded or not), `onboardingDone`, `activeMode`, `availableModes`, `isDeleting`.

| # | Condition | Result |
|---|-----------|--------|
| 1 | Deep link `jaiza://…` | `/splash` (as today, widget links) |
| 2 | `/splash` | stay |
| 3 | `isDeleting` | `/app/delete-account` (progress) |
| 4 | Not signed in and onboarding not done | `/onboarding` |
| 5 | Not signed in and the route is in the **guest allow-list** (`/welcome /login /signup /phone /reset-password /app/today /app/mosques/** /app/more /app/about /app/academy-intro /app/benefits /app/donation /app/contact`) | stay |
| 6 | Not signed in, any other `/app/**` route | stay on the **current** route and open the Sign-in sheet (return `null` + set `pendingLockedRoute`). For a direct URL on web, redirect to `/login?from=<route>` |
| 7 | Signed in and `needsEmailVerification` | `/verify-email` |
| 8 | Signed in and the user doc is still loading | stay (the screen shows a skeleton; don't bounce) |
| 9 | Signed in and `onboardedModes == false` | `/select-mode` |
| 10 | Signed in and on an auth route (`/welcome /login /signup /phone /select-mode`) | `from` query param if present, else the mode's root |
| 11 | Route belongs to a mode that is **not available** (e.g. `/app/family/**` without Parent) | that mode's setup route if the user tapped "Set up", else the active mode root |
| 12 | Route belongs to an available mode that isn't active | **switch mode automatically** (e.g. a push for "Jama'at report" opens Masjid Admin) and stay |
| 13 | otherwise | stay |

Refresh: `GoRouter(refreshListenable: Listenable.merge([authStateListenable, appUserListenable, activeModeListenable]))`.

## 7. Web specifics
- URL strategy: path URLs (`usePathUrlStrategy()`), with Hosting rewrite `** → /index.html`.
- Auth persistence on web: `Persistence.LOCAL` (default).
- Popups can be blocked on iOS Safari. Fall back to `signInWithRedirect` when `popup-blocked` happens.

## 8. Account deletion (D-024)

### 8.1 UX
1. More → **Delete account**.
2. **Warning screen** (scrollable, red accent). It lists exactly what will be deleted, built from the
   user's real data:
   - Your profile, photo, settings, prayer history (N logs), streaks and Qaza records.
   - Children you manage alone (names listed). Children who also have another guardian are **kept**
     for that guardian — you are only removed.
   - If you own **organization X**: the organization, its N teachers' access, N classes, N students
     and all their attendance. *Transfer ownership first if you want to keep it* (button → 12 §2.4).
   - If you are a masjid admin: you are removed as admin. If you are the **last** admin, the mosque
     stays listed but can't be edited until Al Islaah assigns a new admin.
   - Pending mosque requests and your CNIC record are deleted.
   - "This cannot be undone."
3. A text field: "Type **DELETE** to confirm" (not case-sensitive, trimmed; Urdu UI still asks for
   the Latin word `DELETE`).
4. **Re-authenticate** based on the providers linked to the account:
   - password → password field → `reauthenticateWithCredential(EmailAuthProvider.credential)`
   - Google → `reauthenticateWithProvider(GoogleAuthProvider())` (web: popup)
   - Apple → `reauthenticateWithProvider(AppleAuthProvider())` — **keep the `authorizationCode`**
     from the result; it is needed to revoke the Apple token (Apple requires this)
   - phone → send an OTP → `reauthenticateWithCredential(PhoneAuthProvider.credential)`
5. The button becomes active only when steps 3 and 4 are done. Tap ⇒ callable
   `deleteAccount({confirm: 'DELETE', appleAuthorizationCode?})`.
6. Progress screen. When done, sign out locally, clear local user caches, go to `/welcome`, and show
   "Your account was deleted".

### 8.2 Server (`deleteAccount` callable, 08 §4)
```
require auth; require data.confirm == 'DELETE'
require auth.token.auth_time within last 5 minutes   // proves the user just re-authenticated
mark users/{uid}.deletion = {status:'running', at}   // the client listens for progress
1. children where guardianUids contains uid:
     if guardianUids.length == 1 → recursiveDelete(children/{id})   (includes prayers, stats, qaza)
     else → arrayRemove(uid) from guardianUids
2. if modes.org.role == 'admin' → deleteOrganizationCascade(orgId)
   (invites, teachers, classes, students where orgId, their prayers/stats, linkCodes; then update each
    removed teacher's users.modes.org = null)
   if modes.org.role == 'teacher' → delete organizations/{orgId}/teachers/{uid}; classes stay (admin reassigns)
3. for each mosque in modes.masjidAdminOf → arrayRemove uid from adminUids; if empty → flag
   mosques/{id}.needsAdmin = true
4. mosqueRequests where requesterUid == uid → delete (+ mosqueRequestsPrivate + Storage files)
5. Storage: delete users/{uid}/** 
6. recursiveDelete(users/{uid})   // prayers, stats, qaza, devices, …
7. feedback docs by uid → anonymize (keep the message, remove uid/email)
8. admin.auth().revokeRefreshTokens(uid)
   (Apple token: the CLIENT revokes it just before calling this function, with
    FirebaseAuth.instance.revokeTokenWithAuthorizationCode(authorizationCode) on iOS.
    On Android/web Apple sign-in, call Apple's /auth/revoke REST endpoint from this function
    using the Apple private key stored in Secret Manager.)
9. admin.auth().deleteUser(uid)
10. write deletionLog/{random} = {at, counts}   // no personal data; for audits only
```
Use `firestore.recursiveDelete()` from the Admin SDK (it deletes subcollections). Run with a 540 s
timeout and 1 GiB memory. The function is **idempotent**: if it fails half-way, calling it again
continues.
