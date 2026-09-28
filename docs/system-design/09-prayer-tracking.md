# 09 — Prayer Tracking (Fard, Nawafil, Qaza, times, streaks, offline, widgets)

## 1. Namaz times (calculated)

- Engine: `adhan_dart` in `services/prayer_times_service.dart` (exists). The same algorithm runs on
  the server with the npm `adhan` package (for "after azan" Jama'at rules and server-side checks).
  **Both** must use the same inputs. `jaiza_core` keeps a table of test cases (city, date, method →
  expected times) that both the Dart and TypeScript tests run. If they ever differ by more than 1 minute,
  the build fails.
- Inputs: `lat, lng, date, calcMethod, madhab, timezone`.
- Location order:
  1. `prayerSettings.useGps == true` and permission granted → last known position (refresh when the
     app opens if older than 6 h, or moved > 5 km).
  2. Manual city (`manualLat/lng/label`). In Pakistan, pick from a built-in list of ~150 cities
     (`assets/data/pk_cities.json`: name en/ur, province, lat, lng).
  3. Nothing → **don't show times**. Show the "Enable location / choose city" card (D-017). The
     current fallback to Mecca is **removed** for Pakistan users (it showed wrong times without
     saying so).
- Defaults (D-095): in PK, `karachi` + `hanafi`. Outside PK, `muslimWorldLeague` + `shafi` (the
  user can change both).
- **Prayer windows** (used for marking and reminders):

| Prayer | Window start | Window end |
|--------|--------------|-----------|
| Fajr | Fajr | Sunrise |
| Zuhr | Dhuhr | Asr |
| Asr | Asr | Maghrib |
| Maghrib | Maghrib | Isha |
| Isha | Isha | next day's Fajr *(end reminder: 30 min before midnight point, see below)* |

- Isha's "end reminder" fires at the **Islamic midnight** (halfway between Maghrib and next Fajr)
  minus `endReminderMinutes`, because most people sleep before Fajr. Show this rule in settings text.
- Nawafil windows (derived, for display): Tahajjud (last third of the night → Fajr), Ishraq
  (Sunrise + 15 min → +45 min), Chasht (Ishraq end → Dhuhr − 10 min), Awwabin (after Maghrib → Isha).

## 2. Day boundary & `dateKey`

- The **prayer day** starts at **Fajr**, not midnight. Isha prayed at 01:00 belongs to the
  **previous** date. `dateKeyForPrayer(prayer, now)` handles it: if `now < today's Fajr` and prayer is
  Isha (or Tahajjud/Witr), use yesterday's dateKey.
- `dateKey` uses the device's local time zone (the user's `timezone`). Children use the guardian's
  device time zone. Students use **PKT** (the madrasa's time zone).
- Travel: if the device time zone changes, new marks use the new zone. Old logs aren't changed.

## 3. Fard & Nawafil marking

### 3.1 States of one prayer row
| State | Condition | UI |
|-------|-----------|----|
| Upcoming | now < window start | Grey, time shown, **not tappable** ("Starts at 4:45") |
| Open | start ≤ now < end, not marked | Highlighted, "Mark as prayed" + countdown to end |
| Prayed | log `completed` | Green check, time of marking |
| Missed | log `missed`, or window ended with no log | Red/amber. "Mark as prayed (late)" still allowed for 8 days — it stays a completed log (a late prayer still counts); Qaza math uses only real `missed` + unmarked ended windows |
| Locked | dateKey older than 8 days | Read-only |

### 3.2 Actions
- Tap → `completed` (optimistic, 04 §5). Long-press or the ⋮ menu → `missed` / `clear`.
- Snackbar "Marked Asr as prayed · Undo" (5 s). Undo writes the previous state.
- "With Jama'at" toggle (optional) on Fard rows when a primary mosque is set → `inJamaat: true`.
- Marking a Fard as `completed` **cancels** its pending end reminder (exists today:
  `NotificationsService.cancelForPrayer`).
- Writes go to `SubjectRef.path/prayers/{dateKey}_{prayer}_{type}` with `set()`; `clear` = `delete()`.

### 3.3 Who can mark whom
| Subject | Who writes | Where |
|---------|-----------|-------|
| Self | the user | `users/{uid}/prayers` |
| Child | any guardian | `children/{id}/prayers` (`source: 'guardian'`) |
| Student | class teacher or org admin | `students/{id}/prayers` (`source: 'teacher'`) |
| Student (seen by parent) | nobody else | read-only for linked guardians |

## 4. Qaza

### 4.1 Concepts
- **Estimate** (per prayer): years/months/days of missed prayers **before** Jaiza, entered in the
  wizard. `estimateCount = years*365 + months*30 + days` (per prayer, since each day has one of
  each prayer). *(Today's code multiplies by 5 in `estimatedQazaPrayers` for the legacy combined
  field — the per-prayer plan must not.)*
- **Tracked missed**: Fard windows since `trackingSince` that ended with `missed` or no log.
- **Completed**: the sum of `count` on Qaza logs for that prayer.
- `remaining = max(0, estimate + trackedMissed − completed)`.
- Order of paying back (display only): tracked days first (oldest first), then the estimate — same as
  the current `QazaPrayerSummary.madeUpOn`.

### 4.2 Logging make-ups
- Qaza screen: per prayer a big **+1** button and a small −1 (for mistakes, same day only).
- Write: `…/prayers/{todayKey}_{prayer}_qaza` with `count: FieldValue.increment(±1)`.
  Rules allow 0–50 per doc. The UI blocks going below 0.
  *(Offline: `increment` is queued and merged correctly.)*
- Daily goal (`qazaPlan.dailyGoal`, 1–50) → progress ring "3 of 5 today" and
  `daysToFinish = ceil(remaining / dailyGoal)`, `finishDate = today + daysToFinish`.

### 4.3 Server counters (D-071)
`stats/qaza` is recomputed by `recomputeDay` when a Fard or Qaza log changes, and by
`nightlyStreakRollover` for yesterday's unmarked windows:
```
trackedMissed[p] = count of days since trackingSince where dailySummaries.fard[p] != 'completed'
                   (days with an ended window only; today counts only after the window ended — server
                    uses the subject's timezone + calculated times; if location unknown, treat Isha end
                    as next-day 04:00 local)
completed[p]     = sum of qaza counts (kept incrementally: +delta from the log's before/after count)
```
To stay cheap, `trackedMissed` is kept **incrementally** too: each daily summary write adjusts it by
the change in that day's status (before vs after). A full recompute runs only from a maintenance
script.

### 4.4 Qaza reminder (D-063)
Daily local notification at `qazaPlan.reminder.time`: "Qaza today: 2 of 5 done. 1,204 remaining."
The text is refreshed each time the app opens (local notifications can't compute text at fire time).
Skip it if today's goal is already met when scheduling.

## 5. Streaks & badges (Function-owned)

- A **perfect day** = all 5 Fard `completed` for that dateKey.
- `current` = number of perfect days in a row ending **today or yesterday** (a streak isn't broken
  until today's day is over).
- `longest` = best ever. Badges from `kBadgeDefinitions` (exists): `first_step` (1), `week_warrior`
  (7), `month_light` (30), `nawafil_nur` (10 Nawafil total). Future badges are added in `jaiza_core`
  **and** `functions/src/lib/badges.ts`.
- The client shows `stats/streak` only. **Delete** the client streak writer
  (`StreakRepository` writes) during migration.
- Parent screens show each child's streak. Teacher screens show class averages from
  `dailySummaries`.

## 6. Records (history)

- Month calendar (`table_calendar`, exists) with a dot per **perfect** day and a small ring showing
  `fardDone/5` for other days — from `dailySummaries` for the month (one query, ≤ 31 docs).
- Day detail sheet: the 5 Fard + Nawafil + Qaza count for that day (reads the logs for that dateKey).
- Month stats: perfect days, % Fard prayed, most-missed prayer.
- Hijri date shown under the Gregorian date (package `hijri`, exists). Hijri date can be off by a
  day in Pakistan; add a setting "Hijri adjustment −1/0/+1".

## 7. Offline behaviour (D-070)

| Action | Offline result |
|--------|---------------|
| Mark / clear / Qaza +1 | Saved locally at once; syncs later. UI shows it as done |
| Streak / summaries | Stay at the last server value until sync. Today's ring is computed **locally** from logs as a preview, so it looks right offline |
| Records of past months | From cache if viewed before; otherwise "Connect to load" |
| Two devices mark the same prayer offline | Last write wins (deterministic id). Acceptable |
| Rules reject a queued write (e.g. clock was wrong) | The Firestore SDK drops it and the stream reverts. `PrayerMarkController` listens for `permission-denied` and shows a snackbar |

Web: `persistenceEnabled: true` needs IndexedDB. If it fails (private window, or another tab owns
it), the app works online-only and shows no error.

## 8. Home widgets (Android/iOS only)

Keep the current design (`home_widget`, `HomeWidgetBridge`, background `homeWidgetCallback`).
Changes needed:
1. The background callback writes to `users/{uid}/prayers/{dateKey}_{prayer}_fard` (new path) with
   `source: 'widget'`. It must compute `dateKey` the same way as the app (§2) — move that function to
   `jaiza_core`.
2. The widget always shows **Individual** data (self), whatever the active mode.
3. Widget data refresh: after any mark, at each prayer start (piggy-back on the scheduled start
   notification), and when the app opens.
4. Show the **Jama'at time** of the primary mosque under each prayer if set.
5. Signed-out / guest: the widget shows "Sign in to track" and the next namaz time only (if location is
   known).
