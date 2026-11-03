# Kakeibo Design System — MASTER

> Global source of truth for the app's look, feel and motion. A page-specific file in `design-system/kakeibo/pages/<page>.md` overrides this one for that screen only.
> Built from the PRD (§8) and the **ui-ux-pro-max** skill: style `minimalism-and-swiss-style`, product rules for *Personal Finance Tracker*, UX guidelines, the Flutter stack guidance and the pro-rules pre-delivery checklist. Every colour pair below was measured against WCAG 2.2.
>
> **Deviations from the skill's default finance recommendation (on purpose):** the skill suggests *glassmorphism + dark navy + trust blue*. We use **calm paper & ink**, because Kakeibo is a mindful, handwritten-ledger practice (PRD §1.2, §8). The skill's own secondary pick for finance, *Minimalism & Swiss*, is the base we build on.

---

## 1. Design principles

| # | Principle | In practice |
|---|---|---|
| 1 | **Calm, not alarming** | Warm paper background, ink text, soft muted pillar colours. Overspending is shown honestly but never in screaming red or with shaming copy. |
| 2 | **One thing per screen** | Each screen answers one question (How much is left? What did I spend? How did the month go?). One primary action per screen. |
| 3 | **Fast hands, slow mind** | Logging takes ≤ 3 taps and ≤ 5 s. Reflection is deliberately slower, roomy and guided. |
| 4 | **Numbers first** | Money is the hero: big, tabular, well formatted (`Rs 1,250,000.00`, LKR with cents). Labels support the numbers and never compete with them. |
| 5 | **Smooth and predictable** | 60 fps everywhere, instant feedback (≤ 100 ms), motion that explains where things came from, no jank, no layout jumps. |
| 6 | **Accessible by default** | Contrast ≥ 4.5:1 for text, ≥ 3:1 for controls; touch targets ≥ 48 dp; colour never the only signal; works at 200% text and with TalkBack. |

---

## 2. Colour tokens

Semantic tokens only. Screens never use raw hex (Flutter: `Theme.of(context)` + `ThemeExtension<KakeiboColors>`).

### 2.1 Core surfaces & text

| Token | Light | Dark | Use | Contrast check |
|---|---|---|---|---|
| `bg` | `#F6F1E7` *washi paper* | `#151412` *sumi* | App background | — |
| `surface` | `#FFFCF6` | `#1F1D1A` | Cards, sheets | — |
| `surfaceSunken` | `#EFE8DA` | `#100F0D` | Keypad well, inputs, track of bars | — |
| `ink` | `#1F1C18` | `#EEE8DC` | Primary text, big numbers | 15.1 : 1 on bg (both) |
| `ink2` | `#5A5349` | `#B4AC9E` | Secondary text, labels | 6.7 / 8.2 : 1 |
| `ink3` | `#6B6357` | `#948C7F` | Hints, captions, placeholders | 5.3 / 5.5 : 1 |
| `divider` | `#E3DACB` | `#3A3631` | Decorative separators only | decorative |
| `outline` | `#8E8475` | `#7A7267` | Input borders, control boundaries, focus ring base | 3.6 / 3.6 : 1 on surface |
| `primary` | `#2B2925` *ink button* | `#EEE8DC` | Primary buttons, FAB, selected nav | — |
| `onPrimary` | `#FFFFFF` | `#151412` | Text/icons on primary | 14.5 / 15.1 : 1 |
| `seal` | `#B7322C` *hanko red* | `#E06A60` | Brand mark, the "saved" stamp, tiny accents only | 5.3 / 5.6 : 1 |
| `scrim` | `#1F1C18` @ 40% | `#000000` @ 60% | Behind sheets and dialogs | measured on real bg |

### 2.2 Pillar colours (the four Kakeibo categories)

Traditional Japanese hues, muted for calm. Each pillar **always** has an icon and a label too, never colour alone.

| Pillar | Token | Light | Dark | Icon (Material Symbols) | Meaning |
|---|---|---|---|---|---|
| Needs | `pillarNeeds` | `#3D6B4C` *matsuba pine* | `#7FB08E` | `house_rounded` | Survival essentials |
| Wants | `pillarWants` | `#A24A22` *kaki persimmon* | `#E39467` | `shopping_bag_rounded` | Optional pleasures |
| Culture | `pillarCulture` | `#6A568F` *fuji wisteria* | `#AE9BD6` | `menu_book_rounded` | Growth: books, courses, art |
| Unexpected | `pillarUnexpected` | `#2D628C` *ai indigo* | `#7CB0DA` | `bolt_rounded` | One-offs, emergencies |

Each pillar also gets a soft container tint: `pillarXContainer` = pillar colour at **12%** over `surface` (light) / **18%** (dark), with the pillar colour used for text on it.

### 2.3 Status colours

| Token | Light | Dark | Use (always with icon + text) |
|---|---|---|---|
| `calm` | pillar colour | pillar colour | Budget usage < 75% |
| `caution` | `#875B0C` *yamabuki* | `#E0B25A` | 75–100% used · icon `warning_rounded` |
| `over` | `#A8322D` *beni* | `#EE8A84` | > 100% used, negative remaining · icon `cancel_rounded` |
| `success` | `#3D6B4C` | `#7FB08E` | Goal met, backup done · icon `check_circle_rounded` |
| `info` | `#2D628C` | `#7CB0DA` | Tips, help |

All text-capable status colours are ≥ 5 : 1 on `bg` and `surface` in both themes.

---

## 3. Typography

Fonts are **bundled in the APK** (offline app; both are SIL OFL): **Lora** for display, **Inter** for UI and numbers.

| Role | Token | Font / weight | Size / line height | Notes |
|---|---|---|---|---|
| Hero number | `displayMoney` | Inter 600, **tabular figures** (`FontFeature.tabularFigures()`) | 40 / 44 | Remaining amount on the dashboard |
| Screen title | `headline` | Lora 600 | 26 / 32 | One per screen |
| Section title | `title` | Lora 600 | 20 / 26 | Cards, wizard steps |
| Card number | `moneyM` | Inter 600 tabular | 22 / 28 | Pillar totals, summary rows |
| Body | `body` | Inter 400 | 16 / 24 | Default text, never smaller for paragraphs |
| Body strong | `bodyStrong` | Inter 600 | 16 / 24 | |
| Label | `label` | Inter 500 | 14 / 20 | Buttons, chips, nav labels |
| Caption | `caption` | Inter 400 | 13 / 18 | Dates, hints (minimum size for text) |
| Reflection prose | `reflection` | Lora 400 | 18 / 28 | Reflection questions and answers: a calm, notebook feel |

Rules: scale with system text size (no `textScaler` clamping below 2.0); right-align money in lists; currency symbol in `ink2` at 0.7× of the number size, **always rendered through `MoneyFormatter`** so the user's symbol format (`Rs`, `Rs.`, `LKR`, `රු`, before/after) applies everywhere — never type a symbol in a widget; negative amounts written `−Rs 1,500` (true minus sign) in `over` colour plus an icon.

---

## 4. Spacing, shape, elevation

**Spacing (4/8 dp rhythm):** `s1 4` · `s2 8` · `s3 12` · `s4 16` · `s5 24` · `s6 32` · `s7 48` · `s8 64`
- Screen gutter: 20 dp on phones (< 600 dp wide), 32 dp on larger widths; content max width 560 dp, centred.
- Between cards: 12 dp. Inside cards: 16 dp padding (20 dp for hero card).
- Section spacing tiers: 16 / 24 / 32 / 48.

**Radius:** `rSm 8` (chips, inputs) · `rMd 14` (cards, buttons) · `rLg 24` (bottom sheets, top corners) · `rFull` (FAB, pills).

**Elevation:** paper feels flat. Cards use a 1 dp `divider` border, no shadow. Only floating things get a shadow:
- `e1` FAB & snackbar: `0 2 8` at 12% ink (dark: 40% black).
- `e2` bottom sheet: `0 -4 24` at 10% ink.

**Texture (optional, P2):** a very subtle paper grain on `bg` at 3% opacity, which must be off when "reduce motion / high contrast" is on.

---

## 5. Iconography

- One family: **Material Symbols, Rounded** (`material_symbols_icons`, e.g. `Symbols.home_rounded`). Use outline (`fill: 0`) for UI and filled (`fill: 1`) only for the selected nav item and the active pillar chip. *(Phosphor was the first choice, but `phosphor_flutter` was abandoned in 2024 and does not compile on Flutter 3.47.)*
- Sizes: `iconSm 16` · `iconMd 24` (default) · `iconLg 32` (pillar buttons) · `iconXl 48` (empty states).
- No emoji as icons. The mood tag shows a Material Symbols face icon (`sentiment_satisfied` / `sentiment_neutral` / `sentiment_dissatisfied`) **plus** a text label (Worth it / Neutral / Regret).
- Decorative icons next to a text label are excluded from semantics; icon-only buttons get a `tooltip` / `Semantics(label:)`.

---

## 6. Motion: what makes the app feel smooth

Motion explains, and never decorates. At most 1–2 animated elements per view. Every animation must respect **Remove animations** (`MediaQuery.disableAnimationsOf(context)`), which falls back to an instant change or a 100 ms fade.

| Token | Duration | Curve | Use |
|---|---|---|---|
| `tapFeedback` | 90 ms | `easeOut` | Ripple/press tint (no scale that shifts layout) |
| `micro` | 150 ms | `easeOutCubic` | Chip select, toggle, icon swap |
| `standard` | 250 ms | `easeOutCubic` (enter) / `easeInCubic` 200 ms (exit) | Cards appearing, page content |
| `sheet` | 300 ms | `Curves.easeOutQuart` / spring-like `fastOutSlowIn` | Quick-add bottom sheet up; exits faster (220 ms) |
| `progress` | 600 ms | `easeOutCubic` | Pillar bars and savings ring filling when values change |
| `number` | 400 ms | `easeOutCubic` | Hero amount count-up/down after saving an entry |
| `page` | 300 ms | Material shared-axis (horizontal for wizard steps, fade-through for tabs) | Navigation |

Smoothness rules:
- **Optimistic UI:** after Save, the sheet closes and the dashboard numbers animate at once. The DB write is < 100 ms, and an error rolls back with a snackbar.
- **Haptics:** `HapticFeedback.selectionClick()` on pillar select, `lightImpact()` on Save, none elsewhere.
- **Hero transition** from the FAB `+` to the quick-add sheet amount field, so the user sees where it came from.
- Lists use `ListView.builder`/slivers, keys on items, and `RepaintBoundary` around animated rings/bars. Dispose every `AnimationController`.
- Never animate layout size of text blocks; animate opacity/transform only.
- First frame target < 1.5 s cold start; show the dashboard skeleton (shapes in `surfaceSunken`) for at most 300 ms rather than a spinner.

---

## 7. Components

### 7.1 Buttons
| Variant | Look | Use |
|---|---|---|
| **Primary** | `primary` fill, `onPrimary` label, height 52 dp, `rMd`, full width in sheets | One per screen: Save, Continue, Finish reflection |
| **Secondary** | `surface` fill, 1 dp `outline`, `ink` label | Alternatives: Skip, Edit plan |
| **Text** | No container, `ink` label + underline on focus | Tertiary: Not now, Learn more |
| **Destructive** | `over` text button; filled `over` only inside the final confirm dialog | Delete, Reset app |
Disabled: 38% opacity, no ripple, `Semantics(enabled:false)`. Min target 48 × 48 dp, 8 dp gap between targets.

### 7.2 FAB (quick add)
- 64 dp circle, `primary`, `Symbols.add_rounded` 28 dp, `e1`, centred and docked in the bottom bar.
- Semantics label: "Add expense". Long-press opens "Add income / refund".

### 7.3 Bottom navigation
- 4 destinations: **Home · Transactions · History · Settings**, plus the centre FAB. Material 3 `NavigationBar`, height 72 dp, labels always visible.
- Selected: filled icon + `ink` label + soft indicator pill (`surfaceSunken`). Unselected: regular icon + `ink2`.
- Tapping the active tab scrolls to top / returns to the tab root.

### 7.4 Cards
- `surface`, 1 dp `divider` border, `rMd`, 16 dp padding.
- **Hero card (dashboard):** remaining amount (`displayMoney`), per-day allowance with (?) info icon, period + days left, savings ring.
- **Action card:** contextual prompts (Plan not set, Reflect on last month, Back up data, Getting started checklist). Left 4 dp accent strip in the relevant status colour, one text button.

### 7.5 Pillar progress bar
```
[icon] Needs                    Rs 6,200 / Rs 10,000
██████████████░░░░░░░░  62%
```
- Track `surfaceSunken`, fill = pillar colour (caution/over colours replace it at thresholds), height 10 dp, `rFull`.
- Always shows % text and, at caution/over, the status icon. Over 100%: the bar is full and a small "+Rs 1,200 over" caption appears.
- Tappable: opens the Transactions list filtered to that pillar.
- Semantics: "Needs, 6,200 of 10,000 rupees spent, 62 percent".

### 7.6 Savings ring
- 96 dp ring, 10 dp stroke, track `surfaceSunken`, fill `success`; centre shows `%` and "of Rs 10,000 goal".
- When the goal is reached, the **hanko stamp** animates once (seal-red "saved" stamp, scale 1.2 → 1.0, 300 ms). It is skipped under reduced motion.

### 7.7 Quick-add bottom sheet (the most important component)
Layout top → bottom, opens with the keypad ready (no system keyboard):
1. Drag handle; amount display `displayMoney` with blinking caret; currency symbol in `ink2`.
2. **Pillar selector:** a 2 × 2 grid of large tiles (min 64 dp tall): icon `iconLg` + label, pillar container tint. Selected tile: pillar colour fill, white label, check icon. **Required** before Save is enabled.
3. Optional row: note field (with recent-note chips below), date chip (Today ▾), payment chip (UPI ▾), mood chips (3).
4. Custom numeric keypad: 3 × 4 grid of 64 dp keys (`surfaceSunken`), keys `1–9`, `00`, `0`, `⌫` (long-press clears), plus decimal key only if the currency uses minor units.
5. **Save** primary button, full width, pinned above the safe area.

The sheet takes up to 92% of the height, with a `scrim` behind. Swipe down or back dismisses, with a "Discard?" prompt only if an amount was typed.

### 7.8 Chips
Height 36 dp (48 dp hit area), `rSm`, 1 dp `outline`; selected = `ink` fill, `onPrimary` text + check icon.

### 7.9 Inputs
- Filled style: `surfaceSunken` fill, 1 dp `outline` border, 2 dp `ink` border on focus, label always visible above the field (never placeholder-only), helper text below, error text in `over` plus an icon directly under the field.
- Money inputs are right-aligned, use tabular figures, and format live (100,000).

### 7.10 Lists (transactions)
- Grouped by day with sticky headers ("Today", "Yesterday", "Mon, 3 Nov") and a day total on the right.
- Row 64 dp: pillar icon in a 40 dp tinted circle · note (or pillar name) + time/payment caption · amount right-aligned.
- Swipe left to delete (with undo snackbar) **and** a long-press menu with Edit / Delete as a non-gesture alternative.

### 7.11 Snackbar
`ink` background, `bg` text, `e1`, 4 s, a single action ("Undo"), placed above the bottom nav and FAB.

### 7.12 Dialogs & confirmations
Only for destructive or irreversible actions. Title in `title`, one sentence of body, actions right-aligned: Cancel (text) · Delete (destructive).

### 7.13 Onboarding & guide components (PRD §6.10)
- **Welcome card:** a full-bleed illustration area (line art in `ink2` with one pillar-colour accent), `headline` title, 2-line body, progress dots, a Next primary button and a Skip text button top-right.
- **Coach mark:** a scrim with a rounded cut-out around the target (8 dp padding), a tooltip card in `surface` with an arrow, 1–2 sentences, "Got it" text button, "1 of 3" step text. Tapping anywhere advances it.
- **(?) info sheet:** a small bottom sheet with a formula written in words and an example with real numbers.
- **Checklist card:** checkbox rows; done items get a check icon in `success` and a strike-through in `ink3`.
- **Empty state:** `iconXl` line icon in `ink3`, `title`, one-line `body`, one primary or text action.

### 7.14 Reflection wizard
- One question per page, `reflection` typography, generous 32 dp spacing, a multi-line field that grows.
- Top: thin progress bar (steps 1–6). Bottom: Back (text) and Next (primary).
- The summary page uses the pillar bars and a large "You saved Rs X" line with the hanko stamp if the goal was met.

---

## 8. Screen patterns

| Screen | Pattern | Primary action |
|---|---|---|
| Dashboard | Hero card → action card(s) → 4 pillar bars → recent 5 → "See all" | FAB + |
| Transactions | Search + pillar filter chips (sticky) → grouped list | FAB + |
| Plan month | Stepper: Income → Fixed → Savings goal → Split → Review (live Spendable at the top, sticky) | Confirm plan |
| Reflection | Wizard (7.14) | Finish |
| History | Month cards (saved amount, goal met badge, mini stacked bar of pillars) → tap → month detail | — |
| Settings | Grouped list sections: Money · Reminders · Security · Data · Help · About | — |

Charts (History): use **horizontal stacked bars / bar charts** with direct labels for the pillars (≤ 4 categories). Avoid pie charts because of the accessibility risk. Provide a list/table fallback below each chart.

---

## 9. Voice & microcopy

- Second person, short, kind, specific: "Rs 444 a day keeps you on track." / "You're Rs 1,500 over in Wants — that's okay, let's see why at the end of the month."
- Never: "You failed", "Bad", exclamation-heavy celebration, guilt.
- Numbers always include the currency and the period ("this month", "this week").
- Buttons are verbs: Save, Plan my month, Start reflection, Back up now.

---

## 10. Accessibility rules (summary)

- Text contrast ≥ 4.5 : 1 (all text tokens above pass in both themes); controls and meaningful icons ≥ 3 : 1 (`outline` passes).
- Touch targets ≥ 48 × 48 dp, with ≥ 8 dp between them.
- Every pillar and status state is shown by colour **and** icon **and** text.
- TalkBack: logical focus order (top → bottom), `Semantics` labels with full money phrases, live-region announcement after saving ("Saved 240 rupees to Needs").
- Text scaling to 200% without clipping; layouts wrap and scroll rather than truncate money.
- Reduced motion respected (section 6). Swipe actions have button alternatives.
- PIN pad supports TalkBack, and the biometric prompt is offered first.

---

## 11. Flutter implementation map

```dart
// lib/app/theme/kakeibo_colors.dart
@immutable
class KakeiboColors extends ThemeExtension<KakeiboColors> {
  const KakeiboColors({
    required this.bg, required this.surface, required this.surfaceSunken,
    required this.ink, required this.ink2, required this.ink3,
    required this.divider, required this.outline, required this.seal,
    required this.needs, required this.wants, required this.culture,
    required this.unexpected, required this.caution, required this.over,
    required this.success, required this.info,
  });
  final Color bg, surface, surfaceSunken, ink, ink2, ink3, divider, outline,
      seal, needs, wants, culture, unexpected, caution, over, success, info;

  static const light = KakeiboColors(
    bg: Color(0xFFF6F1E7), surface: Color(0xFFFFFCF6), surfaceSunken: Color(0xFFEFE8DA),
    ink: Color(0xFF1F1C18), ink2: Color(0xFF5A5349), ink3: Color(0xFF6B6357),
    divider: Color(0xFFE3DACB), outline: Color(0xFF8E8475), seal: Color(0xFFB7322C),
    needs: Color(0xFF3D6B4C), wants: Color(0xFFA24A22), culture: Color(0xFF6A568F),
    unexpected: Color(0xFF2D628C), caution: Color(0xFF875B0C), over: Color(0xFFA8322D),
    success: Color(0xFF3D6B4C), info: Color(0xFF2D628C),
  );
  static const dark = KakeiboColors(
    bg: Color(0xFF151412), surface: Color(0xFF1F1D1A), surfaceSunken: Color(0xFF100F0D),
    ink: Color(0xFFEEE8DC), ink2: Color(0xFFB4AC9E), ink3: Color(0xFF948C7F),
    divider: Color(0xFF3A3631), outline: Color(0xFF7A7267), seal: Color(0xFFE06A60),
    needs: Color(0xFF7FB08E), wants: Color(0xFFE39467), culture: Color(0xFFAE9BD6),
    unexpected: Color(0xFF7CB0DA), caution: Color(0xFFE0B25A), over: Color(0xFFEE8A84),
    success: Color(0xFF7FB08E), info: Color(0xFF7CB0DA),
  );
  // copyWith + lerp (lerp each Color with Color.lerp) omitted for brevity
}
```

- `ThemeData(useMaterial3: true, colorScheme: ColorScheme(...from tokens...), extensions: [KakeiboColors.light])`, with the matching `darkTheme`; `themeMode` comes from settings.
- Typography: `TextTheme` built from tokens; money styles get `fontFeatures: [FontFeature.tabularFigures()]`.
- Spacing / radius / durations: `abstract final class Space { static const s4 = 16.0; ... }`, `Radii`, `Motion` (durations + curves). There are no magic numbers in widgets.
- Packages: `material_symbols_icons` (icons), `animations` (shared-axis/fade-through), `fl_chart`, `showcaseview` (coach marks).
- Access in widgets: `final c = Theme.of(context).extension<KakeiboColors>()!;`
- Money text: `ref.watch(moneyFormatterProvider).format(cents)` returns the number string and symbol separately, so the symbol can be styled (`ink2`, 0.55×) and placed before or after per the user's setting (`Rs 8,450` / `8,450 LKR`). Default `Rs`, 2 decimals shown in lists and inputs, hidden on the hero number when the cents are .00.

---

## 12. Do / Don't

| Do | Don't |
|---|---|
| Paper background, ink text, one accent per element | Glassmorphism, gradients, neon, dark-navy "fintech" look |
| Big tabular numbers with currency formatting | Tiny or unformatted numbers, proportional digits that jitter while animating |
| Colour + icon + text for every state | Red/green alone to mean bad/good |
| One primary button per screen | Several competing filled buttons |
| Instant optimistic feedback + subtle motion | Spinners for local operations, bouncing/overshooting everything |
| Gentle, specific microcopy | Guilt, shame, all-caps warnings |
| Material Symbols Rounded, outline vs filled used consistently | Emoji as icons, mixed icon sets |

---

## 13. Pre-delivery checklist (run for every screen)

From `ui-ux-pro-max/references/pro-rules.md`, trimmed to this app:

- [ ] Semantic tokens only: no hex, font sizes or durations hard-coded in widgets
- [ ] Light **and** dark checked separately; text ≥ 4.5 : 1, controls ≥ 3 : 1
- [ ] Touch targets ≥ 48 dp, 8 dp spacing, pressed feedback within 80–150 ms, no layout shift on press
- [ ] Tested on a 360 dp-wide phone, a large phone and a tablet/landscape; content max width 560 dp
- [ ] Safe areas respected; lists not hidden behind the nav bar / FAB / pinned Save button
- [ ] Remove-animations and 200% text tested without breakage
- [ ] TalkBack focus order and labels checked; icon-only buttons named; decorative icons hidden
- [ ] Colour is never the only indicator (pillars, statuses, mood)
- [ ] Swipe actions have a button alternative; destructive actions confirm or offer undo
- [ ] Empty, loading (skeleton ≤ 300 ms), error and overspend states implemented
- [ ] Animations at 60 fps in profile mode (DevTools), controllers disposed, `RepaintBoundary` on rings/bars
