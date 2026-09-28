# 12 — Organization (Madrasa) Mode

## 1. Roles
| Role | How you get it | Can |
|------|---------------|-----|
| **Org admin** | `createOrganization` (anyone, D-040) | Everything in the org; may also teach classes (D-043) |
| **Teacher** | Email invite accepted (D-041) | Own classes: students, marking, reports, parent codes |
| **Linked parent** | Student link code (11 §5) | Read one student's attendance |
| **Al Islaah reviewer** | Dashboard | Verified badge |

One account: at most **one** org, as admin **or** teacher (D-043). It can still be Individual,
Parent and Masjid Admin at the same time.

## 2. Organization admin

### 2.1 Create (`/app/org/setup`)
Name (3–80), type (madrasa / school / academy / other), city (PK list), address (optional) →
`createOrganization`. Organization mode unlocks. First-run checklist on the org Today screen:
☐ Invite a teacher ☐ Create a class ☐ Add students ☐ Mark the first prayer ☐ Request verification.

### 2.2 Teachers (`/app/org/teachers`)
- **Invite**: email → client writes `organizations/{orgId}/invites/{emailLower}` (`pending`,
  `invitedBy`). If the email already has a claimed invite → "Already a teacher here" (existing
  `TeacherAlreadyActiveException`).
- Optional email notice: with the **Trigger Email** Firebase extension (SMTP, e.g. a Google Workspace
  or SendGrid account), `onInviteCreated` sends "You're invited to teach at X on Jaiza — sign in with
  this email". Without the extension, the admin tells the teacher (a Share button makes the message).
- **Pending invites**: revoke (status `revoked`) or delete.
- **Teachers list**: name, email, classes count, last marking date. Tap → teacher detail (existing
  `admin_teacher_screen.dart`) → their classes, "Remove teacher" (`removeTeacher`: their classes move
  to the admin).
- **Transfer ownership** to a teacher (`transferOrganization`) — needed before the admin deletes
  their account if they want the org to live on.

### 2.3 Verified badge (D-040)
- Org settings → "Get verified by Al Islaah" → form: contact person, phone, note, optional document →
  `requestOrgVerification` → `verification.status = 'requested'`.
- The dashboard reviewer approves or rejects. Verified orgs show a ✓ badge next to their name in the
  teacher's app, on report cards and on the parent's madrasa card.
- Verification can be removed by Al Islaah at any time.

### 2.4 Org settings
Name, type, city, address · Allow parents to link (on/off) · Remove all parent links · Transfer
ownership · Delete organization (type the org name; `deleteOrganization`).

## 3. Teacher: accepting an invite
- `ensureUserProfile` returns `pendingTeacherInvite` on sign-in (only for a verified email).
- The mode chooser (or a banner in any mode) shows "**Jamia X** invited you to teach — Accept /
  Decline" → `acceptTeacherInvite` / `declineTeacherInvite`.
- If the user is already in another org → "You're already part of *Y*. Leave it first to join *X*."
- Removed from the org → the next app open shows "You were removed from X" and Organization mode
  disappears (the `modes.org` field changed).
- This replaces today's client-side `findPendingInvite` + `claimInvite` (security holes 07 §1).

## 4. Classes
- Create: name (e.g. "Hifz-2"), section (optional, e.g. "Morning" — D-045, moves from the
  device-only `classSectionsProvider` to `classes.section`), teacher (admin picks any teacher or
  themself; a teacher creating a class is assigned automatically).
- The admin sees all classes; a teacher sees only theirs.
- Reassign teacher (admin): `onClassWritten` updates `students.teacherUid` for that class.
- Delete class (admin): only if it has no **active** students (move or deactivate them first).

## 5. Students (`students/{sid}`, D-046)
- Add one: name (required), father's name, roll no., gender.
- **Bulk add** (existing `add_students_screen.dart`): paste names, one per line (≤ 100 at a time) →
  a batched write of up to 100 docs (under the 500-writes-per-batch limit).
- Edit, move to another class (`classId` change → the trigger copies the new teacher), deactivate
  ("Left madrasa"), reactivate. Hard delete: admin only (`removeStudent(hardDelete: true)`).
- Student detail (existing `student_detail_screen.dart`): today's marks, month calendar, streak,
  attendance %, parent access (link code + linked parents count).

## 6. Class marking (F-75, existing `class_mark_screen.dart`)
- Pick a prayer chip (defaults to the **current** prayer window; shows the time).
- A list of active students with a big tap target each: tap cycles **unmarked → prayed → missed →
  unmarked**. "Saved as you tap" (optimistic, offline-safe; writes
  `students/{sid}/prayers/{dateKey}_{prayer}_fard` with `markedBy: teacherUid`, `source: 'teacher'`).
- "Mark all as prayed" button, then tap the absent ones → missed.
- Filter "Unmarked only" (exists).
- `dateKey` for students uses **PKT** (09 §2). Teachers can mark today and the last 7 days (D-075);
  a date picker at the top allows going back.
- Teachers only mark prayers that happen at the madrasa. There's no rule for which ones — the teacher
  chooses. The report counts only the prayers that were marked (see §7.2 "Denominator").
- Local teacher reminder (D-045): "Hifz-2: Zuhr not marked yet" at window end − 15 min, only on the
  days/prayers the teacher enables (existing `classRemindersOnProvider`, device only).

## 7. Report cards — PDF on the device (D-044)

### 7.1 Kinds
| Report | Content |
|--------|---------|
| **Class report** (weekly / monthly) | Header (org logo/name, ✓ if verified, class, teacher, period) · summary tiles (average attendance %, perfect-attendance students, most-missed prayer) · a table: student × days (✓ / ✗ / –) for weekly, or student × prayer % for monthly · top 3 regular students (optional "star" section) · footer (generated on, "Made with Jaiza") |
| **Student report card** (weekly / monthly) | Header · student name, father's name, roll no. · a big attendance ring · per-prayer bars (Fajr … Isha %) · month calendar grid with colours · streak & badges · a teacher's remark (typed before generating, not stored) · **parent link code + QR** (if parent linking is on and the code is valid) · a signature line |

### 7.2 Calculations
- Period: **week** = Mon–Sun (PKT) that contains the chosen date; **month** = calendar month.
- For each student and prayer: `prayed = count(completed)`, `missed = count(missed)`,
  `marked = prayed + missed`.
- **Denominator = marked prayers only** (unmarked ones are "not recorded", shown as "–").
  `attendance% = prayed / marked`. When `marked == 0`, show "No records".
- Data source: `students/{sid}/dailySummaries` for the period (≤ 31 docs per student). For a class of
  40, a monthly report reads ≤ 1,240 small docs — acceptable, and cached afterwards. Show a progress bar
  while loading.

### 7.3 Implementation
- Packages: `pdf` (layout), `printing` (preview + print + share on Android/iOS/web),
  `share_plus` (WhatsApp etc.), `qr` / `barcode` (the `pdf` package's barcode widget draws QR codes).
- Fonts: embed **Noto Sans** (Latin) and **Noto Naskh Arabic** (Urdu) as assets and load them with
  `pw.Font.ttf`. Urdu text in PDFs uses **Naskh**, not Nastaliq: the `pdf` package's Arabic shaping
  works with Naskh; Nastaliq ligatures won't render correctly.
  Use `textDirection: pw.TextDirection.rtl` for Urdu blocks.
- Page: A4 portrait (student card) or A4 landscape (weekly class table). Class tables with > 25
  students continue on the next pages (`pw.MultiPage`, header repeated).
- Build the PDF in a background **isolate** (`compute`) on mobile so the UI doesn't freeze; on web
  build it on the main thread with a progress indicator.
- Design: the app's colours (cream `#FBF3E3`, green/gold accents from `app_theme.dart`), rounded
  cards, generous spacing, the Jaiza emblem watermark at 5 % opacity. A designer mock-up should be
  approved first; `reports_pdf/` keeps one widget per section so the layout is easy to change.
- Actions after generating: Preview (in-app), Share, Print, Save (Android/iOS: share sheet "Save to
  Files"; web: download).
- The existing "PDF export is coming soon" snackbar in `class_report_screen.dart` is replaced by this.

## 8. Org "Today" screen (admin)
Today's marking progress per class ("Hifz-2: Zuhr 32/40 marked"), classes not marked for the current
prayer, the week's average attendance, and pending invites.

## 9. Edge cases
| Case | Behaviour |
|------|-----------|
| Teacher removed while marking offline | Queued writes are rejected by the rules and dropped; the app shows "You no longer have access to this class" |
| Admin deletes their account without transferring | Warning (05 §8); the whole org is deleted |
| Student moved to another class mid-month | Reports use the **student's** logs, so history moves with the student; the class report lists students **currently** in the class, with a note "joined on …" |
| Same student in two classes | Not allowed (one `classId`). Use two records if truly needed |
| 200+ students in one class | Marking list is virtualised (`ListView.builder`); reports paginate |
