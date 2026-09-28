# 16 — Localization (English + Urdu) & Responsive UI

## 1. Localization setup (D-090)

`l10n.yaml` (root):
```yaml
arb-dir: lib/core/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: L10n
synthetic-package: false
output-dir: lib/core/l10n/gen
nullable-getter: false
```
`pubspec.yaml`: `flutter: generate: true` and `flutter_localizations: {sdk: flutter}`.

`MaterialApp.router(localizationsDelegates: L10n.localizationsDelegates, supportedLocales: L10n.supportedLocales, locale: ref.watch(localeProvider))`.

- `localeProvider`: `users/{uid}.locale` when signed in; the device prefs value for guests; else the
  device locale if it is `ur`, else `en`.
- Access in widgets: `final t = L10n.of(context);` → `Text(t.markAsPrayed)`.
- **No hard-coded user-facing strings** in widgets. The current `AppStrings` class (only 11 strings) and
  literal strings across screens move to ARB. CI check: a simple script fails the build when a
  `Text('…')` with letters is found in `lib/features/**/presentation` (allow-list for debug-only text).

### 1.1 ARB rules
```json
// app_en.arb
{
  "@@locale": "en",
  "markAsPrayed": "Mark as prayed",
  "prayerMarked": "{prayer} marked as prayed",
  "@prayerMarked": { "placeholders": { "prayer": { "type": "String" } } },
  "qazaRemaining": "{count, plural, =0{No Qaza remaining} =1{1 Qaza remaining} other{{count} Qaza remaining}}",
  "@qazaRemaining": { "placeholders": { "count": { "type": "int", "format": "decimalPattern" } } },
  "jamaatIn": "Jama'at in {minutes} min",
  "@jamaatIn": { "placeholders": { "minutes": { "type": "int" } } }
}
```
```json
// app_ur.arb
{
  "@@locale": "ur",
  "markAsPrayed": "ادا کر لی",
  "prayerMarked": "{prayer} ادا ہو گئی",
  "qazaRemaining": "{count, plural, =0{کوئی قضا باقی نہیں} other{{count} قضا باقی}}",
  "jamaatIn": "جماعت {minutes} منٹ میں"
}
```
- Keys: `camelCase`, grouped by feature prefix (`mosque…`, `qaza…`, `family…`).
- Prayer names come from ARB (`prayerFajr` = "Fajr" / "فجر"), never from `enum.name`.
- Urdu translations must be reviewed by a native speaker from Al Islaah before release. Religious terms
  follow the Academy's spelling (Jama'at/جماعت, Qaza/قضا, Nawafil/نوافل).
- Dates/numbers: `DateFormat.yMMMd(locale)`, `NumberFormat.decimalPattern(locale)`. Digits: use Latin
  digits in Urdu UI by default (more readable for times); make it a setting later if people ask.
- Hijri month names: from the `hijri` package with the `ur` locale, or our own ARB list.
- Server-sent text (push): 08 §3 (both languages in the payload).

### 1.2 Fonts
- English: the current `google_fonts` choice.
- Urdu: **Noto Nastaliq Urdu** for body text (traditional look) — **bundle it as an asset**
  (don't download at runtime: offline + no flash). Nastaliq is **tall**: use `height: 1.8–2.0` for
  Urdu text styles, and never give Urdu text a fixed-height container.
  Use **Noto Naskh Arabic** for dense UI (chips, table cells, numbers) where Nastaliq would be too tall,
  and for PDFs (12 §7.3).
- `ThemeData` builds `TextTheme` per locale: `AppTheme.textTheme(locale)`.

## 2. RTL rules
- Flutter mirrors layout automatically for `ur`. Our code must not break it:
  - Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`,
    `BorderRadiusDirectional`, `start/end` — **never** `left/right` for layout.
  - Icons that point a direction (back, forward, chevrons, "send") must mirror: use
    `Icons.adaptive.arrow_back`, or `Transform.flip(flipX: Directionality.of(context) == TextDirection.rtl)`.
  - Don't mirror: clocks, media controls, numbers, the compass/Qibla, charts' time axis
    (keep time flowing left → right; mark this in the chart widget).
  - Mixed text (Urdu with an English mosque name or a time): wrap LTR parts with
    `Bidi`-safe widgets or add `‎` (LRM) around times like `5:30 PM`.
- Lint: add a custom check (grep in CI) for `EdgeInsets.only(left` / `right:` in `lib/features`.

## 3. Responsive layout

### 3.1 Breakpoints (extend `core/layout/app_breakpoints.dart`)
| Name | Width | Layout |
|------|-------|--------|
| compact | < 600 | Bottom navigation bar, single column |
| medium | 600–899 | `NavigationRail`, 2-column where useful (list + detail) |
| expanded | ≥ 900 | `NavigationRail` (extended ≥ 1200), content max width 900 (existing `MaxWidthBody`), master-detail for Mosques, Classes, Records |

Use `LayoutBuilder` / `MediaQuery.sizeOf(context)` — **not** `MediaQuery.of(context).size` (it
rebuilds on every inset change).

### 3.2 Rules that prevent overflow (D-091) — MUST
1. **No fixed heights on anything that contains text.** Use `minHeight` constraints and padding.
2. In a `Row`, every text is inside `Expanded`/`Flexible`, with `maxLines` and
   `overflow: TextOverflow.ellipsis` where a cut-off is acceptable (names), or wrapping where it isn't
   (instructions).
3. Buttons: `FilledButton` with text that can wrap to 2 lines; never a fixed width. Button rows become a
   `Wrap` or a `Column` when they don't fit (`OverflowBar` does this automatically).
4. Screens scroll: every screen body is a `CustomScrollView`/`ListView`/`SingleChildScrollView`, even
   if it "fits" on a big phone. Forms use `SafeArea` + `viewInsets` padding for the keyboard.
5. Big numbers / times in cards: `FittedBox(fit: BoxFit.scaleDown)` so "12:45 PM" never overflows.
6. Grids: `SliverGridDelegateWithMaxCrossAxisExtent` (the count adapts), not fixed `crossAxisCount`
   (replace `hubGridCrossAxisCount` usage over time).
7. Bottom sheets: `isScrollControlled: true` + `DraggableScrollableSheet` for long content.
8. Text scaling: support system text scale up to **2.0**. Clamp only if a design truly breaks, and then to
   no less than 1.5: `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.6)` at the app root is
   acceptable as a first step.
9. Images/Lottie: size relative to the width (`AspectRatio`), with max sizes.
10. Dialogs: max width 560, scrollable content.
11. Tables (reports, dashboard): horizontal scroll inside a `Scrollbar` on narrow screens.

### 3.3 Required checks for every screen (PR checklist)
| Check | How |
|-------|-----|
| 320 × 568 (small Android / iPhone SE 1st gen) | Device Preview (web debug) or emulator |
| 375 × 812 and 412 × 915 | common phones |
| Tablet 768 × 1024 and web 1440 × 900 | rail layout |
| Urdu (RTL) | switch the language in the app |
| Text scale 1.5 and 2.0 | device settings / Device Preview |
| Landscape phone | no clipped content (scroll is fine) |
| Dark mode | contrast |
| No yellow-black overflow stripes, no `RenderFlex overflowed` in the debug console | watch the log |

Automate the main ones with **golden tests** (`flutter_test` + `matchesGoldenFile`) for Today, Mosque
detail, Timetable editor, Mode chooser, Class marking and the Sign-in sheet, in `{en, ur} × {1.0, 2.0}`
at 320 and 412 widths.
