# Jaiza — System Design (Source of Truth)

**Product:** Jaiza (Jaiza-Namaz) by Al Islaah Academy
**Owner:** Hamza Munir
**Written:** 28 Sep 2026, from branch `ui-redesign` (commit `74d5c61`)
**Status:** Approved design. Developers **must** follow it. Any change goes through the
[Decision Log](01-decisions.md) first (add a new decision; never silently diverge).

> This folder replaces the design parts of `docs/PROJECT_OVERVIEW.md`. Where the two disagree,
> **this folder wins**. `PROJECT_OVERVIEW.md` stays only as history.

---

## How to use this folder

1. Read **01 → 05** before writing any code. They set the rules for everything else.
2. Before you build a feature, read that feature's file (09–14, 17). It lists every screen,
   rule, edge case and the exact Firestore paths to use.
3. When you touch Firebase, follow **15-firebase-setup-guide.md** step by step.
4. When you write UI, follow **16-localization-and-responsive-ui.md**. Any screen that overflows at
   320 px width, with Urdu, or at 1.5× text size is a bug.
5. Build in the order given in **18-roadmap-and-migration.md**.

## Files

| # | File | What it covers |
|---|------|----------------|
| 00 | [README](00-README.md) | This index, glossary, conventions |
| 01 | [Decision Log](01-decisions.md) | **Every** product and technical decision, with the reason |
| 02 | [Product features](02-product-features.md) | Every mode, every feature, guest rules, conditions |
| 03 | [Architecture](03-architecture.md) | Repo layout (monorepo), app layers, folder structure, packages |
| 04 | [State management](04-state-management.md) | Riverpod 3 rules, provider catalog, freezed models, migration from Riverpod 2 |
| 05 | [Auth, modes & routing](05-auth-modes-routing.md) | Sign-in methods, guest mode, multi-mode accounts, mode switcher, router, account deletion |
| 06 | [Data model](06-data-model.md) | Complete Firestore schema, Storage paths, indexes |
| 07 | [Security rules](07-security-rules.md) | Full `firestore.rules` and `storage.rules`, and the holes in the current rules |
| 08 | [Cloud Functions](08-cloud-functions.md) | Every function (TypeScript): triggers, callables, schedules, skeleton code |
| 09 | [Prayer tracking](09-prayer-tracking.md) | Fard, Nawafil, Qaza, prayer times, streaks, offline, home widgets |
| 10 | [Mosques & Jama'at](10-mosques-and-jamaat.md) | Register, review, CNIC encryption, admins, timetable, scheduled changes, nearby search, Mapbox, reports |
| 11 | [Parent mode](11-parent-mode.md) | Children, co-parent invite codes, madrasa link, family reminders |
| 12 | [Organization mode](12-organization-mode.md) | Madrasa, teachers, classes, students, marking, PDF report card, verified badge |
| 13 | [Notifications](13-notifications.md) | Local reminders, FCM, topics, iOS 64 limit, Android exact alarms, web push |
| 14 | [Admin dashboard](14-admin-dashboard.md) | Separate Flutter web app for Al Islaah staff |
| 15 | [Firebase setup guide](15-firebase-setup-guide.md) | Step-by-step console + CLI setup for Android, iOS, web, Functions, KMS, App Check… |
| 16 | [Localization & responsive UI](16-localization-and-responsive-ui.md) | English + Urdu (RTL), ARB, overflow rules, breakpoints |
| 17 | [Other features](17-other-features.md) | Profile photo, donation, contact, about, analytics, Crashlytics, Remote Config |
| 18 | [Roadmap & migration](18-roadmap-and-migration.md) | Phases, migration from current code/data, testing, release checklist |

## Glossary

| Term | Meaning |
|------|---------|
| **Fard** | The 5 obligatory daily prayers: Fajr, Zuhr, Asr, Maghrib, Isha |
| **Nawafil** | Optional prayers (Tahajjud, Ishraq, Chasht, Awwabin, Witr, Rawatib…) |
| **Qaza** | Making up a missed Fard prayer |
| **Namaz / Azan time** | Start of a prayer window. Jaiza **calculates** it on the device with `adhan_dart` from location + method + madhab |
| **Jama'at / Iqamah time** | When the congregation starts at a mosque. It is **published by that mosque's admin**, never calculated |
| **Mode** | One "face" of an account: Individual, Parent, Organization, Masjid Admin. One login can have several modes (see D-010) |
| **Subject** | The person a prayer log belongs to: the user themself, a child, or a madrasa student |
| **Guardian** | A parent account that manages a child. A child can have up to 4 guardians |
| **Platform admin** | Al Islaah staff. Uses the admin dashboard. Identified by a Firebase custom claim |
| **Masjid admin** | A verified person who may edit one mosque's Jama'at times. Up to 3 per mosque |
| **Link code** | A short, one-time code (e.g. `K7P-3QX`) created by a Cloud Function to connect two accounts safely |
| **PKT** | Pakistan Standard Time, `Asia/Karachi`, UTC+5, no daylight saving |

## Conventions used in these docs

- **MUST / MUST NOT** = a hard rule. Code review rejects violations.
- **SHOULD** = the default. You may deviate only if you write down why in the PR.
- Firestore paths are written like `users/{uid}/prayers/{logId}`.
- Times are 24-hour `HH:mm` strings in **mosque-local time** (PKT for v1) unless the doc says UTC.
- Dates used as keys are `YYYY-MM-DD` in the **subject's local calendar** (called `dateKey`).
- "Callable" = an HTTPS Callable Cloud Function called from Flutter with `cloud_functions`.
