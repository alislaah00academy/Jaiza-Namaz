# 15 — Firebase Setup Guide (step by step)

Follow these in order. Tick each box in the PR description of the setup work.
The project already exists: **`jaiza-namaz`** (Android app registered with `google-services.json`;
`lib/firebase_options.dart` has Android, iOS, web and Windows configs; **`ios/Runner/GoogleService-Info.plist`
is missing**).

> Console menu names change from time to time. If a name below doesn't match exactly, search the
> console for it — the steps stay the same.

## 1. Tools (each developer)
- [ ] Flutter (stable) and Dart matching `sdk: ^3.11.0`.
- [ ] Node.js 22 LTS (for Functions and the Firebase CLI).
- [ ] Firebase CLI: `npm i -g firebase-tools` → `firebase login`.
- [ ] FlutterFire CLI: `dart pub global activate flutterfire_cli`.
- [ ] Google Cloud CLI (`gcloud`) — needed for KMS, backups and scripts: `gcloud auth login`,
      `gcloud config set project jaiza-namaz`, `gcloud auth application-default login`.
- [ ] Java 17 (Android build + Firestore emulator), Xcode (latest) + CocoaPods for iOS.
- [ ] Access: the owner adds each developer in Console → Project settings → **Users and permissions**
      with the smallest role that works (*Firebase Develop Admin* for most; *Owner* only for the owner).

## 2. Project-level settings
### 2.1 Plan and budget (D-005)
- [ ] Console → ⚙ → **Usage and billing** → *Modify plan* → **Blaze**. Link a billing account.
- [ ] Google Cloud Console → **Billing → Budgets & alerts** → create a budget for project
      `jaiza-namaz`: USD 50/month with alerts at 20 %, 50 %, 100 % (≈ 10, 25, 50) to the owner's email.

### 2.2 Link the local repo
```bash
cd Jaiza-Namaz
firebase use --add            # pick jaiza-namaz, alias "default"
```
This creates/updates `.firebaserc`.

### 2.3 Check the Firestore region (D-006)
- [ ] Console → **Firestore Database**. The location shows at the top/Settings tab.
  - If it's **asia-south1** → nothing to do.
  - If it's something else (e.g. `nam5`/`us-central`) → the region **can't be changed**. Choose:
    (a) keep it, and set the Functions region to the nearest supported region to that database
        (same multi-region continent), updating `setGlobalOptions({region})` and the Flutter
        `FirebaseFunctions.instanceFor(region:)`; or
    (b) if there are no real users yet, create a **new named database** in `asia-south1`, point the app
        to it (`FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'jaiza')`) and migrate
        the test data. Record the choice as a new decision.
- [ ] If Firestore doesn't exist yet: Create database → **Production mode** → location
      **asia-south1 (Mumbai)**.

## 3. Register the apps (FlutterFire)
Run from the repo root:
```bash
flutterfire configure --project=jaiza-namaz \
  --platforms=android,ios,web \
  --android-package-name=<your.android.applicationId> \
  --ios-bundle-id=<your.ios.bundleId> \
  --out=lib/firebase_options.dart
```
- [ ] Check the Android `applicationId` in `android/app/build.gradle(.kts)` and the iOS bundle id in
      Xcode (Runner target → General) **before** running it. They must be final — changing them later
      means registering new apps.
- [ ] This writes `android/app/google-services.json` and **`ios/Runner/GoogleService-Info.plist`**
      (the missing file). Open `ios/Runner.xcworkspace` and make sure the plist is inside the
      *Runner* target (drag it into Xcode if needed, "Copy items if needed" ✓).
- [ ] Commit `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`. (They are
      not secrets; API keys are protected by App Check + API restrictions — §10.)
- [ ] Remove Windows/macOS entries from `firebase.json` / options if they won't be supported (D-001), or
      leave them unused.

## 4. Authentication
Console → **Authentication** → *Get started* (if not done) → **Sign-in method**.

### 4.1 Email/Password
- [ ] Enable *Email/Password* (leave *Email link* off).
- [ ] **Settings → User account linking**: "Link accounts that use the same email" (one account per
      email, D-022).
- [ ] **Settings → Password policy**: require at least 8 chars, a letter and a number; *Enforce*.
- [ ] **Settings → User actions**: keep *Email enumeration protection* **on**.
- [ ] **Templates**: edit the Verification and Password reset emails (sender name "Jaiza", English
      template; add Urdu text below the English text since one template serves all). Later, set a
      custom domain for the sender.
- [ ] **Settings → Authorized domains**: add `jaiza-namaz.web.app`, `jaiza-namaz.firebaseapp.com`,
      `jaiza-admin.web.app`, any custom domain, and `localhost`.

### 4.2 Google
- [ ] Enable *Google*; set the public-facing name "Jaiza" and support email.
- [ ] **Android SHA fingerprints** (Project settings → Your apps → Android):
  ```bash
  cd android && ./gradlew signingReport   # copy SHA-1 and SHA-256 of debug and release
  ```
  Add **debug**, **release (upload key)** and, after the first Play upload, the **Play App Signing**
  key (Play Console → Setup → App integrity). Then download the new `google-services.json`.
- [ ] **iOS**: in `Info.plist` add a URL scheme = the `REVERSED_CLIENT_ID` from
      `GoogleService-Info.plist` (CFBundleURLTypes). `google_sign_in` needs it.
- [ ] **Web**: nothing extra for `signInWithPopup`. For `google_sign_in` on web (not used — we use
      `signInWithPopup`), you'd need a meta client id.

### 4.3 Phone
- [ ] Enable *Phone*.
- [ ] **Settings → SMS region policy** → *Allow* only **Pakistan (PK)** (D-023).
- [ ] Add test numbers (e.g. `+92 300 0000001` → code `123456`) for development — no SMS cost.
- [ ] Android: SHA-256 already added (§4.2) + the **Play Integrity API** enabled for the project
      (Google Cloud Console → APIs) so silent verification works.
- [ ] iOS: APNs set up (§6.2) for silent push verification. Also add the **Encoded App ID** URL scheme
      (`app-1-170319084683-ios-…`, shown in Firebase iOS app settings) to `Info.plist` for the
      reCAPTCHA fallback.
- [ ] Web: reCAPTCHA is automatic (invisible). Authorized domains must include the site.

### 4.4 Apple
1. [ ] Apple Developer account → **Certificates, IDs & Profiles**:
   - App ID (the iOS bundle id) → enable **Sign In with Apple**.
   - Create a **Services ID** (e.g. `com.alislaah.jaiza.signin`) → enable Sign In with Apple →
     *Configure*: primary App ID = the app; **Domains** = `jaiza-namaz.firebaseapp.com`; **Return
     URL** = `https://jaiza-namaz.firebaseapp.com/__/auth/handler`.
   - Create a **Key** with Sign In with Apple enabled → download the `.p8` (once only!) → note the
     **Key ID** and your **Team ID**.
2. [ ] Firebase → Sign-in method → **Apple** → enable → Services ID, Team ID, Key ID, private key.
3. [ ] Xcode → Runner → *Signing & Capabilities* → **+ Sign In with Apple**.
4. [ ] Save the `.p8`, Key ID and Team ID in **Secret Manager** as `APPLE_PRIVATE_KEY`,
       `APPLE_KEY_ID`, `APPLE_TEAM_ID` too (for token revocation on account deletion, 05 §8.2):
   ```bash
   firebase functions:secrets:set APPLE_PRIVATE_KEY < AuthKey_XXXX.p8
   ```
5. [ ] Android/web use the web flow (`signInWithProvider` / `signInWithPopup`) — no extra setup
       beyond the Services ID.

### 4.5 Multi-factor for staff (recommended, 14 §1)
- [ ] Authentication → Settings → upgrade to **Identity Platform** (free tier covers our scale).
- [ ] Enable **SMS multi-factor**. Staff enroll from the dashboard's profile page.

## 5. Web apps & Hosting
- [ ] Project settings → *Add app* → Web → "Jaiza Admin" (the main web app already exists).
- [ ] `flutterfire configure --project=jaiza-namaz --platforms=web --out=admin_dashboard/lib/firebase_options.dart`
      and pick "Jaiza Admin".
- [ ] Hosting → *Get started* → set up the 2 sites/targets (14 §6).
- [ ] Custom domains (optional): Hosting → *Add custom domain* → follow the DNS steps.

## 6. Cloud Messaging (FCM)
### 6.1 Android
- [ ] Nothing else in Firebase. In the app, create notification **channels** at startup (13 §1) and add
      the default channel meta-data to `AndroidManifest.xml`:
  ```xml
  <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id"
             android:value="jamaat_changes"/>
  <meta-data android:name="com.google.firebase.messaging.default_notification_icon"
             android:resource="@drawable/ic_stat_jaiza"/>
  ```
  (Add a white-on-transparent `ic_stat_jaiza` icon.)
### 6.2 iOS
- [ ] Apple Developer → Keys → create an **APNs** key (.p8) (can be the same key as Sign in with
      Apple if both boxes are ticked, but a separate key is cleaner).
- [ ] Firebase → Project settings → **Cloud Messaging** → Apple app → upload the APNs auth key (Key ID,
      Team ID).
- [ ] Xcode → Runner → Capabilities: **Push Notifications**, **Background Modes** → *Remote
      notifications* and *Background fetch*.
### 6.3 Web
- [ ] Project settings → Cloud Messaging → **Web Push certificates** → *Generate key pair* → copy
      the **VAPID** public key → `--dart-define=VAPID_KEY=…`.
- [ ] Add `web/firebase-messaging-sw.js` (13 §6).

## 7. Cloud Storage
- [ ] Console → **Storage** → *Get started* → Production mode → location: **the same as Firestore**
      (asia-south1). The bucket is `jaiza-namaz.firebasestorage.app` (in `firebase_options.dart`).
- [ ] Deploy `storage.rules` (07 §3): add to `firebase.json`:
  ```json
  "storage": { "rules": "storage.rules" }
  ```
  then `firebase deploy --only storage`.
- [ ] CORS for web (needed to read images/PDFs with `getData()` in the browser):
  ```json
  [{ "origin": ["https://jaiza-namaz.web.app", "https://jaiza-admin.web.app", "http://localhost:5000"],
     "method": ["GET"], "maxAgeSeconds": 3600 }]
  ```
  `gcloud storage buckets update gs://jaiza-namaz.firebasestorage.app --cors-file=cors.json`
- [ ] Backup bucket: `gcloud storage buckets create gs://jaiza-namaz-backups --location=asia-south1`,
      plus a lifecycle rule to delete objects older than 30 days.

## 8. Cloud KMS (CNIC, D-052)
```bash
gcloud services enable cloudkms.googleapis.com
gcloud kms keyrings create jaiza --location=asia-south1
gcloud kms keys create cnic --keyring=jaiza --location=asia-south1 \
  --purpose=encryption --rotation-period=365d --next-rotation-time=$(date -u -v+365d +%Y-%m-%dT%H:%M:%SZ)
# Give ONLY the Functions runtime service account encrypt/decrypt:
gcloud kms keys add-iam-policy-binding cnic --keyring=jaiza --location=asia-south1 \
  --member="serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com" \
  --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
firebase functions:secrets:set CNIC_HMAC_KEY      # paste a random 64-char string (openssl rand -hex 32)
```
- 2nd-gen Functions run as the **default compute service account** unless you set `serviceAccount`.
  **Recommended:** create a dedicated `jaiza-functions@jaiza-namaz.iam.gserviceaccount.com`, give it
  the roles it needs (Firestore user, Storage admin on the bucket, FCM sender, KMS on this key only,
  Secret accessor), and set `setGlobalOptions({ serviceAccount: 'jaiza-functions@…' })`.
- (`date -v+365d` is macOS syntax; on Linux use `date -u -d '+365 days' +%Y-%m-%dT%H:%M:%SZ`.)

## 9. App Check (D-009)
1. [ ] Console → **App Check** → *Apps*:
   - Android → **Play Integrity** (link the Play Console app; needs the SHA-256 from §4.2).
   - iOS → **App Attest** (and DeviceCheck as fallback for old iOS). Xcode → Capabilities → **App
     Attest** (entitlement `production`).
   - Web (both apps) → **reCAPTCHA Enterprise** → create a site key in Google Cloud Console →
     paste it.
2. [ ] Flutter:
   ```dart
   await FirebaseAppCheck.instance.activate(
     androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
     appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttestWithDeviceCheckFallback,
     webProvider: ReCaptchaEnterpriseProvider(Env.recaptchaSiteKey),
   );
   ```
   (Parameter names can differ between `firebase_app_check` versions — check the package docs for the
   version you install.)
3. [ ] Debug tokens: run a debug build, copy the debug token from the log, and add it in App Check →
       app → *Manage debug tokens*. Every developer adds theirs.
4. [ ] Watch **metrics** for 1–2 weeks (App Check → APIs → "verified vs unverified requests"), then
       click **Enforce** for Firestore, Storage, then Functions (callables use `enforceAppCheck: true`).

## 10. API key restrictions
Google Cloud Console → APIs & Services → **Credentials**: for each auto-created key:
- Android key → restrict to Android apps (package + SHA-1).
- iOS key → restrict to the iOS bundle id.
- Browser key → HTTP referrers: `https://jaiza-namaz.web.app/*`, `https://jaiza-admin.web.app/*`,
  `https://*.firebaseapp.com/*`, `http://localhost:*/*`.
- Limit each key to the APIs Firebase needs (Identity Toolkit, Token Service, Firestore, Firebase
  Installations, FCM Registration, Remote Config, App Check, Analytics…). Test sign-in after each change.

## 11. Cloud Functions
```bash
firebase init functions      # TypeScript, ESLint yes, install deps yes → creates functions/
```
- [ ] Set `"engines": {"node": "22"}` in `functions/package.json`.
- [ ] Install: `npm i firebase-admin firebase-functions @google-cloud/kms luxon zod adhan` and dev:
      `npm i -D @firebase/rules-unit-testing jest ts-jest @types/jest`.
- [ ] Code structure as in 08 §1. First deploy: `firebase deploy --only functions`.
- [ ] The first deploy enables required APIs (Cloud Build, Artifact Registry, Cloud Run, Eventarc,
      Cloud Scheduler). Accept the prompts.
- [ ] Set an Artifact Registry clean-up policy (the CLI offers it) so old build images don't cost money.

## 12. Firestore rules & indexes
```bash
firebase deploy --only firestore:rules      # after 07 rules pass the tests
firebase deploy --only firestore:indexes
```
- [ ] Turn on **Point-in-time recovery** (Firestore → Disaster recovery), 7 days.
- [ ] Scheduled daily export (Function `scheduledBackup`, 08 §2.7). The Functions service account needs
      `roles/datastore.importExportAdmin` and write access to the backup bucket.

## 13. Remote Config
Parameters (defaults in `remoteconfig.template.json`, deploy with
`firebase deploy --only remoteconfig`):

| Key | Type | Example |
|-----|------|---------|
| `min_supported_build` | number | `12` — below this, show a blocking "Please update" screen |
| `donation_url` | string | `https://alislaah.org/donate` |
| `donation_methods_json` | JSON | `[{ "type":"bank","title":"Meezan Bank","account":"…","iban":"…"}, {"type":"jazzcash","number":"…"}]` |
| `contact_whatsapp` | string | `+923001234567` |
| `contact_email` | string | `support@…` |
| `feature_map_view` | bool | `false` |
| `feature_phone_auth` | bool | `true` (kill switch if SMS abuse happens) |
| `privacy_policy_url`, `terms_url` | string | |

App: `RemoteConfig.setDefaults(...)`, `setConfigSettings(fetchTimeout: 10s, minimumFetchInterval: 1h)`,
`fetchAndActivate()` after the first frame.

## 14. Analytics & Crashlytics (D-074)
- [ ] Console → **Analytics** → enable (link or create a Google Analytics account; data location
      as appropriate).
- [ ] Console → **Crashlytics** → enable.
- [ ] Android: add the Crashlytics Gradle plugin (`com.google.firebase.crashlytics`) in
      `android/settings.gradle(.kts)` and `android/app/build.gradle(.kts)`. `flutterfire configure`
      can add it.
- [ ] iOS: add a **Run Script** build phase for dSYM upload (FlutterFire adds it when Crashlytics is
      installed and `flutterfire configure` runs again). For release builds with
      `--obfuscate --split-debug-info`, upload Dart symbols:
      `firebase crashlytics:symbols:upload --app=<APP_ID> build/symbols`.
- [ ] Flutter init (not on web):
  ```dart
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (e, st) { FirebaseCrashlytics.instance.recordError(e, st, fatal: true); return true; };
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  ```
- [ ] Privacy: set `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled` from a user setting
      (on by default, with an off switch in Profile → Privacy). Never log names/emails/phone as
      analytics parameters.

## 15. Emulator Suite (D-004)
```bash
firebase init emulators    # Auth 9099, Functions 5001, Firestore 8080, Storage 9199, UI 4000
firebase emulators:start --import=./emulator-data --export-on-exit
```
In the app (`bootstrap/firebase_bootstrap.dart`):
```dart
if (Env.useEmulators) {
  final host = defaultTargetPlatform == TargetPlatform.android && !kIsWeb ? '10.0.2.2' : 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instanceFor(region: 'asia-south1').useFunctionsEmulator(host, 5001);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
}
```
Run: `flutter run --dart-define=USE_EMULATORS=true`. Add `emulator-data/` to `.gitignore` (or commit a
small seed on purpose).

## 16. CI (GitHub Actions) — recommended
- On every PR: `flutter analyze`, `flutter test`, `dart test packages/jaiza_core`, `npm test` in
  `functions/` (including rules tests with the emulator: `firebase emulators:exec --only firestore "npm test"`).
- On `main`: deploy rules, indexes, functions, hosting (with a service account key stored as a GitHub
  secret, or better, Workload Identity Federation).

## 17. Final checklist before the first public release
- [ ] All boxes above ticked · [ ] Rules tests green · [ ] App Check enforced · [ ] Budget alerts set
- [ ] Privacy policy + terms published (CNIC, location, children's data) and linked in the app and store
      listings · [ ] Play **Data safety** form and App Store **privacy labels** filled in (location,
      contact info, identifiers, crash data) · [ ] Account deletion works for every sign-in method and
      is linked from the Play listing (Play requires a web link too — add a simple page on Hosting:
      "How to delete your account", plus a form/email for users who no longer have the app)
- [ ] Test accounts removed/renamed · [ ] Backups + PITR on
