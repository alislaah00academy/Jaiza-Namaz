# 02 — Product Features & Conditions

This file lists **what** the app does, per mode and per state. The **how** is in files 05–17.
Every feature has an ID (`F-xx`) so PRs and tests can point to it.

---

## 1. App states

The app is always in exactly one of these states. The router (05 §6) enforces them.

| State | Who | What they can reach |
|-------|-----|---------------------|
| **S0 First launch** | Onboarding never finished | Splash → Onboarding (3 pages) → Welcome |
| **S1 Guest** | Not signed in, onboarding done | Guest shell: Today (guest), Mosques, Namaz times, More (limited). All other features shown **locked** |
| **S2 Signed in, not verified** | Email/password account whose email isn't verified | Only `/verify-email` (resend, "I've verified", change email, sign out) |
| **S3 Signed in, no mode chosen yet** | First login after sign-up | Mode chooser `/select-mode` |
| **S4 In a mode** | Normal use | That mode's shell + shared screens |
| **S5 Deleting** | After confirming account deletion | Blocking progress screen until the Function finishes, then back to S1 |

## 2. Guest mode (S1)

### F-01 What a guest can **use**
| Feature | Details |
|---------|---------|
| Nearby mosques | Needs location permission. Radius 5 km, can widen to 10/25 km |
| Search mosques | By name and by city, no location needed |
| Mosque details | Full Jama'at timetable, Jumu'ah, upcoming changes, address, "open in maps" |
| Save mosques / primary mosque | Stored on the device (D-018) |
| Jama'at "X min before" reminders | Local notifications, Android/iOS only |
| Jama'at change alerts | FCM topic, if the guest allows notifications (D-019) |
| Namaz times | Only if location is shared **or** a city is picked by hand (D-017). Shows today's 5 windows + sunrise and a countdown to the next prayer |
| Static content | About, Academy intro, Fazail (Benefits), Donation, Contact (buttons only; the form needs sign-in) |
| Language + theme | Yes |

### F-02 What a guest can **see but not use**
Fard / Nawafil / Qaza tracking, History, Streaks, Parent mode, Organization mode, Masjid admin,
Register mosque, Report a time, Contact form, Home widgets, Profile.

- Each one shows in the UI with a small **lock badge**.
- Tapping it opens the **Sign-in sheet**: the feature name, a one-line benefit, and 3 buttons:
  *Create account*, *Sign in*, *Not now*.
- After sign-in, the user goes back to **the feature they tapped** (the router keeps a `from=` target, 05 §6).

### F-03 Guest → account
On first sign-in or sign-up from a device that has guest data, the app uploads it:
saved mosques, primary mosque, alert settings, and the location/city choice. If the account already
has these settings (existing user on a new phone), **the account wins** and guest data is dropped.
The user sees a snackbar: "Your saved mosques were added to your account."

## 3. Authentication features

| ID | Feature | Conditions |
|----|---------|-----------|
| F-10 | Sign up with email + password | Name (2–50 chars), email, password (min 8, at least 1 letter + 1 number), confirm. Sends verification email |
| F-11 | Sign in with email + password | Wrong password → friendly error. 5 failures → Firebase throttles; show "Try again later or reset password" |
| F-12 | Google sign-in | All platforms. Email is treated as verified |
| F-13 | Apple sign-in | All platforms (on Android/web it runs through a web flow). May hide the email (private relay) — that's fine |
| F-14 | Phone OTP | +92 numbers only (D-023). 6-digit code, resend after 60 s, max 5 resends per hour. Android may auto-read the code |
| F-15 | Forgot password | Sends a reset email. Always shows "If an account exists, we sent an email" (never says whether the email exists) |
| F-16 | Email verification | Resend (60 s cooldown), "I've verified" button reloads the user, auto-check every 5 s while the screen is open |
| F-17 | Link sign-in methods | Profile → Sign-in methods: add or remove Google/Apple/Phone/Password. At least 1 method must remain |
| F-18 | Change password | Only for password accounts. Needs the current password |
| F-19 | Sign out | Clears local caches for the user (not guest mosque prefs), unsubscribes user-specific topics, deletes the device's FCM token doc |
| F-20 | Delete account | See 05 §8. Warning screen + type `DELETE` + re-authenticate |

## 4. Modes

### F-30 Mode chooser (first login) and mode switcher
- Shows 4 cards. Each card has one of these states:

| Mode | Available now | Needs setup | Waiting | Active |
|------|---------------|-------------|---------|--------|
| Individual | always | — | — | ✓ |
| Parent | — | "Add a child" or "Join with a code" | — | has ≥1 child |
| Organization | — | "Create a madrasa" | "Invite found from *X* — Accept?" | admin or teacher of 1 org |
| Masjid Admin | — | "Register your masjid" | "Request under review" | admin of ≥1 mosque |

- Tapping a mode that needs setup opens its setup flow. When setup finishes, the user lands in that mode.
- **Switcher**: a chip in the top app bar ("Individual ▾") + a "Switch mode" row on More. It opens a
  bottom sheet listing active modes, with a "Set up another mode" link that opens the chooser.
- Switching changes the **shell** (tabs), the Today content and the notification behaviour. It never
  changes data (D-012).
- If a mode becomes invalid (teacher removed from org, last mosque admin rights removed, all children
  removed), the app shows a one-time dialog ("You were removed from *X*") and falls back to Individual.

### F-31 Which features appear in each mode

| Feature | Individual | Parent | Organization (admin) | Organization (teacher) | Masjid Admin |
|---------|:--:|:--:|:--:|:--:|:--:|
| Today (own prayers) | ✓ | — (shows children) | — (org summary) | — (my classes) | — (my mosque) |
| Mark own Fard/Nawafil/Qaza | ✓ | via Individual | via Individual | via Individual | via Individual |
| Mosques tab | ✓ | ✓ | ✓ | ✓ | ✓ |
| Records / History | own | per child | per class / student | per class / student | — |
| Children, co-parents, madrasa link | — | ✓ | — | — | — |
| Teachers, invites, verify badge request | — | — | ✓ | — | — |
| Classes, students, marking, reports | — | — | ✓ (all classes) | ✓ (own classes) | — |
| Edit Jama'at, admins, reports inbox | — | — | — | — | ✓ |
| Profile, settings, language, about… | ✓ | ✓ | ✓ | ✓ | ✓ |

Tabs per mode:
- **Individual**: Today · Mosques · Records · More
- **Parent**: Family · Mosques · Records · More
- **Organization**: Today · Classes · Mosques · Records · More (this is the current shell)
- **Masjid Admin**: My Masjid · Reports · Mosques · More

## 5. Individual mode

| ID | Feature | Key conditions (details in 09) |
|----|---------|--------------------------------|
| F-40 | Today: current/next prayer card with countdown, 5 Fard rows with Jama'at time of the primary mosque | Times from `adhan_dart`. Jama'at from the primary mosque's effective schedule for today |
| F-41 | Mark Fard as prayed / missed / clear | Only after the prayer window **has started**. Today + previous 7 days (D-075). Undo snackbar for 5 s |
| F-42 | Nawafil tracking (turn on/off in More) | Shows the Nawafil card on Today when on. Marks done/not done |
| F-43 | Qaza estimate wizard (years/months/days per prayer since puberty) | Can be edited any time; the app recalculates |
| F-44 | Qaza make-up logging | +1 / −1 per prayer, many per day allowed. Counters kept by a Function |
| F-45 | Qaza plan (daily goal, finish date) | Goal 1–50 per day |
| F-46 | Qaza daily reminder at a chosen time | D-063 |
| F-47 | Records: calendar with full-day dots, per-day detail, monthly % | From daily summaries (Function-written) |
| F-48 | Streak + badges | Read-only, from Function (D-071) |
| F-49 | Prayer start / end reminders | Per prayer on/off, custom end message, 10 min before end |
| F-50 | Home widgets (Android + iOS) | Quick mark from the widget. Not on web |
| F-51 | Prayer settings | Method, madhab, GPS or manual city, notification toggles |

## 6. Parent mode (details in 11)
F-60 Add/edit/remove child (name, age, gender, optional photo later) · F-61 Mark a child's Fard/Nawafil ·
F-62 Child Qaza · F-63 Child records and streak · F-64 Co-parent invite code (create/redeem/remove) ·
F-65 Link madrasa (enter student code) and see madrasa attendance read-only · F-66 Family reminders
(local) · F-67 "Needs attention" badge when a child's prayer window ended unmarked.

## 7. Organization mode (details in 12)
F-70 Create organization (name, city, address, type: madrasa/school/academy) · F-71 Invite teacher by
email, revoke invite, remove teacher · F-72 Request the Verified badge · F-73 Classes (name, section,
assigned teacher) · F-74 Add students (single + bulk paste of names) · F-75 Class marking (one prayer
at a time, tap per student, saved as you tap) · F-76 Student detail · F-77 Weekly/monthly PDF report
card (class + student) · F-78 Student link code for parents · F-79 Org setting "Allow parents to link"
· F-80 Local "class not marked" reminders for teachers.

## 8. Mosques (details in 10)
F-90 Nearby / search / detail (everyone) · F-91 Save, set primary, alert toggle, minutes-before ·
F-92 Register a new mosque (3 steps: details + pin → requester + CNIC + proof → review & submit) ·
F-93 Claim admin of an existing mosque · F-94 Request status screen (pending / needs info / approved /
rejected + reason) · F-95 Report a wrong time · F-96 Masjid admin: edit timetable, schedule a change,
Jumu'ah, publish · F-97 Masjid admin: invite/remove co-admins (primary only) · F-98 Masjid admin: reports
inbox (resolve/dismiss) · F-99 Masjid admin: edit public info (phone, photo). Name/location changes go
back to review.

## 9. Everyone (signed in)
F-100 Profile (name, photo, city, phone, language) · F-101 Notifications & widgets settings ·
F-102 Announcements inbox (last 30 from Al Islaah) · F-103 Contact form · F-104 Donation ·
F-105 About / Academy / Fazail · F-106 Theme (light/dark/system, device only) · F-107 Language
(English/Urdu).

## 10. Global conditions (apply everywhere)

1. **Offline**: every read shows cached data. Every write is queued. A small "Offline — changes will sync"
   banner shows when there is no connection. Features that **need** the network (sign-in, register
   mosque, redeem codes, delete account, PDF upload if any) show "Needs internet" and disable the button.
2. **Loading**: never show a blank screen. Use skeletons for lists, spinners only inside buttons.
3. **Errors**: every failed write shows a snackbar with *Retry*. Never show raw Firebase error text;
   map it (extend `core/errors/firebase_auth_messages.dart` into a general `ErrorMapper`).
4. **Time**: all "today" logic uses the **device's local date** for the user and children, and
   **PKT** for mosques and madrasas (v1).
5. **Permissions**: ask for location and notifications **only when the user takes an action that needs
   them** (never on first launch), and always explain first with an in-app sheet.
6. **Empty states**: each list has an illustration/Lottie + one sentence + one action.
7. **Accessibility**: tap targets ≥ 48×48, semantic labels on icon buttons, contrast AA in both themes.
