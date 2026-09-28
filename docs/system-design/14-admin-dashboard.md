# 14 — Al Islaah Admin Dashboard (Flutter Web)

## 1. Decisions
| Topic | Decision | Why |
|-------|----------|-----|
| Tech | **Flutter Web** app in `admin_dashboard/`, same monorepo, using `jaiza_core` | Owner choice; same language, shared models |
| Hosting | **Firebase Hosting**, a second site `jaiza-admin` (e.g. `jaiza-admin.web.app`, later `admin.<domain>`) | Free SSL, same project |
| Sign-in | Email + password **or** Google, then the account **must** have the custom claim `platformRole`. Everyone else gets "No access" | Claims can't be faked by clients |
| Roles | `superAdmin` (everything, manages staff), `reviewer` (queues, reveal CNIC, verify orgs, handle reports) | Least privilege |
| Access to data | Reads with Firestore SDK (rules allow `isPlatform()`), **all writes through callables** (08 §2.6) | One place for validation + audit log |
| 2FA | Turn on **SMS multi-factor** for staff accounts (needs Identity Platform upgrade, free tier is enough) — recommended before launch | Staff accounts can reveal CNICs |
| State / routing | Riverpod 3 + go_router, same rules as the app (04) | Consistency |
| Layout | Desktop-first (≥ 1200 px) with a left `NavigationRail`, also usable on a tablet | Staff work on laptops |

## 2. First super admin (one-time)
```bash
cd functions
npx ts-node scripts/setPlatformRole.ts --email hamza@… --role superAdmin
```
The script uses the Admin SDK with Application Default Credentials (`gcloud auth application-default login`).
After that, the super admin adds other staff from the dashboard (**Staff** page → `setPlatformRole`).
The user must sign out and back in (or the app calls `getIdToken(true)`) to get the new claim.

## 3. Pages

| Page | What it shows | Actions (callables) |
|------|---------------|---------------------|
| **Overview** | Counts: pending requests, escalated reports, orgs awaiting verification, new users (7 d), listed mosques, feedback | — |
| **Mosque requests** | Queue (oldest first), filters: status, kind (new/claim/edit), city. Each row: name, city, requester, age of request, duplicate warning | Open detail |
| Request detail | Left: proposed data + a map pin (flutter_map + Mapbox) + nearby existing mosques (possible duplicates, with distance). Right: requester (name, phone, role at mosque, `cnicLast4`, account age, other requests by this user / **same CNIC fingerprint**), proof documents viewer (images inline, PDF in a viewer; loaded with `getData()` — never a public URL), photos | **Reveal CNIC** (`revealCnic`, shown 30 s, audited) · Approve (with edits to name/location) · Reject (reason required, chosen from a list + free text) · Ask for more info (message) · Mark as duplicate of … |
| **Mosques** | Search/list all mosques, filters: city, listed, needsAdmin, stale timetable (> 60 days) | Edit info · Suspend/restore · Assign/remove admins · View history |
| **Reports** | Escalated + all open reports across mosques | Contact admin (shows phone), resolve on behalf, suspend mosque |
| **Organizations** | List, filters: verification status, city | Verify/reject (note) · Remove badge |
| **Announcements** | Compose title+body in **English and Urdu** (both required), optional deep link, preview on a phone mock, target (all/en/ur) | Send (`sendAnnouncement`, confirm dialog) · list of sent ones |
| **Feedback** | Contact-form messages, status new/read/answered | Change status, reply via email link |
| **Users** | Look up by email/phone/uid (read-only profile, modes, counts) | Disable account (Auth), revoke sessions |
| **Staff** (superAdmin) | Staff with roles | Add/change/remove role |
| **Audit log** (superAdmin) | `platformAudit`: who did what, when | Export CSV |

## 4. Review checklist (shown in the request detail)
1. The pin is on a real mosque (satellite view) and the address matches.
2. Not a duplicate of a listed mosque (≤ 150 m, similar name).
3. The proof names this mosque and looks real (letterhead, stamp, date within 12 months).
4. The requester's name matches the proof; the CNIC last 4 digits match the document if shown. (Reveal
   the full CNIC only if needed.)
5. The phone number answers (optional call for first-time requesters).
6. If unsure → "Ask for more info", don't reject.

## 5. Structure
```
admin_dashboard/
├── pubspec.yaml            # resolution: workspace; depends on jaiza_core, firebase_*, flutter_riverpod, go_router, flutter_map, pdfx (PDF viewer)
├── lib/
│   ├── main.dart           # Firebase init (same project, web app "jaiza-admin"), App Check reCAPTCHA Enterprise
│   ├── auth/               # sign-in, claim gate
│   ├── shell/              # NavigationRail layout
│   ├── features/{overview,requests,mosques,reports,orgs,announcements,feedback,users,staff,audit}/
│   └── core/               # theme (matches the app, desktop density), table widgets
└── web/index.html
```
Firebase: register a **new Web app** "Jaiza Admin" in the same project (15 §5) → its own
`firebase_options.dart` via `flutterfire configure --out=admin_dashboard/lib/firebase_options.dart`.

## 6. Deploy
`firebase.json`:
```json
"hosting": [
  { "target": "app",   "public": "build/web",                  "rewrites": [{ "source": "**", "destination": "/index.html" }] },
  { "target": "admin", "public": "admin_dashboard/build/web",  "rewrites": [{ "source": "**", "destination": "/index.html" }],
    "headers": [{ "source": "**", "headers": [
      { "key": "X-Frame-Options", "value": "DENY" },
      { "key": "Cache-Control", "value": "no-store" } ] }] }
]
```
```bash
firebase target:apply hosting app jaiza-namaz
firebase hosting:sites:create jaiza-admin
firebase target:apply hosting admin jaiza-admin
(cd admin_dashboard && flutter build web --release)
firebase deploy --only hosting:admin
```
Add `robots.txt` with `Disallow: /` to the admin site.
