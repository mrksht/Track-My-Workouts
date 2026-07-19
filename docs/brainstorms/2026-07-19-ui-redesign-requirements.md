---
date: 2026-07-19
topic: ui-redesign
---

# UI Redesign: Light Palette, Responsive Layout, Component Vocabulary

## Problem Frame

`track-my-workout` is a single-user gym tracker used on a phone mid-session and,
occasionally, on a laptop for review. Three things are wrong with its current
interface:

1. **It is dark, and the owner wants light.** The theme is a 13-token `@theme`
   block, but the dark assumption has leaked past it — section colors are built
   as `/20`-opacity tints that only work over a dark surface, the chart tree
   carries nine hardcoded dark hex values, and `bg-[#0f0f1a]` is written
   literally in two places outside the theme.
2. **It has no responsive behavior at all.** There is not one `sm:`/`md:`/`lg:`
   class in the codebase. Content is pinned to `max-w-2xl mx-auto`, so a laptop
   renders a phone-width strip in a large empty field. Reviewing a progress
   chart — the main reason to open it on a laptop — happens in a 250px-tall box
   inside a narrow column.
3. **It has no component vocabulary.** The same card shell, input, badge, and
   spinner are re-implemented across files. This is why the palette change is
   currently expensive: there is no single place to restyle.

The redesign changes how the app looks and lays out. It deliberately does not
change what the app does during a workout.

---

## Requirements

**Visual system**

- R1. Replace the dark `@theme` block with a light palette organized in two
  tiers: a private raw ramp and a semantic tier that components consume
  (`--color-bg`, `--color-surface`, `--color-text`, `--color-text-muted`,
  `--color-border`, `--color-action`, `--color-cool`).
- R2. Add the three scales that do not currently exist: radius, elevation, and
  type. A light palette cannot express depth through surface-lightness steps the
  way the dark one did, so elevation must come from real shadows.
- R3. Every color used in the UI must resolve from a semantic token. No
  hardcoded hex values may remain in component files, including inside the
  Recharts tree and the two `bg-[#0f0f1a]` literals.
- R4. Orange is the action color and appears only as a fill with white text on
  it, never as body text on a light ground. Where orange must be text, it uses
  the darkened variant.
- R5. Light blue is the structural color: active navigation, chart lines,
  informational chips, section identity. It never competes with orange for the
  primary action.
- R6. Orange occupies a small fraction of any given screen. There is at most one
  orange-filled primary action visible at a time.
- R7. All text meets 4.5:1 contrast against its background. Values displayed
  during a workout (weight, reps, duration) meet a higher bar through size and
  weight, not color alone.
- R8. The six-hue `SECTION_COLORS` map collapses onto a single warm-to-cool
  intensity axis, so section color encodes effort rather than acting as an
  arbitrary legend.

**Typography and density**

- R9. Adopt an "athletic and bold" treatment: logged and target values are the
  largest, heaviest elements on screen; labels are small, uppercase, and
  low-emphasis.
- R10. Separation comes primarily from whitespace and type weight rather than
  from borders and filled surfaces.
- R11. Interactive targets during a workout are at least 44px, and numeric
  inputs are large enough to read at arm's length with the phone propped up.

**Responsive layout**

- R12. Introduce three breakpoints: single pane below 600px; a constrained
  column (~540px) that stays constrained rather than stretching at 600px+; and
  a two-pane master-detail layout at 840px+.
- R13. The bottom navigation persists below 600px and becomes a persistent left
  rail at the two-pane breakpoint.
- R14. History and Progress gain real wide layouts at 840px+ — a list or picker
  in the left pane and the selected session or chart in the right pane, both
  visible simultaneously.
- R15. The Workout screen stays phone-shaped at every width. It is centered and
  constrained on wide viewports rather than being expanded into the extra space.
- R16. Charts scale with available width instead of staying at a fixed 250px
  height inside a narrow column.

**Component vocabulary**

- R17. Extract the shapes the codebase already repeats into shared primitives —
  a surface/card shell, a form field, a button, a chip, a layout stack, and a
  loading/empty/error boundary. Each primitive must have at least three existing
  call sites; none are created speculatively.
- R18. Collapse `ExerciseCard`'s three near-duplicate tracking-type branches
  into one declarative field schema keyed by `tracking_type`, so a new tracking
  type is a data change rather than a fourth branch.

---

## Responsive Behavior

| Viewport | Navigation | Dashboard | Workout | History | Progress |
|---|---|---|---|---|---|
| < 600px | Bottom bar | Single column | Single column | List, expand in place | Picker + chart stacked |
| 600–839px | Bottom bar | Constrained ~540px | Constrained ~540px | Constrained ~540px | Constrained ~540px |
| ≥ 840px | Left rail | Multi-column summary | Centered, still ~540px | Two-pane: list + session | Two-pane: picker + chart |

The Workout column intentionally does not grow. Widening a logging surface
nobody uses on a laptop would trade real mobile ergonomics for unused desktop
space.

---

## Acceptance Examples

- AE1. **Covers R3, R7.** Given the light theme is applied, when the Progress
  chart renders, its grid, axes, tooltip, and line all resolve from theme tokens
  and remain legible on the light ground — no element retains a dark-theme hex.
- AE2. **Covers R4, R6.** Given the Dashboard is open, when the screen is
  inspected, exactly one orange-filled action is present and no orange text sits
  directly on the light background.
- AE3. **Covers R12, R15.** Given a 1440px-wide browser window, when the Workout
  screen is open, the logging column is centered at roughly its mobile width
  rather than stretched across the viewport.
- AE4. **Covers R14.** Given a 1440px-wide window, when a session is selected in
  History, the session list and the selected session's detail are both visible
  without navigating away.
- AE5. **Covers R18.** Given a new tracking type were added to the schema, when
  the field schema gains one entry, the set-entry UI renders it without a new
  JSX branch.

---

## Success Criteria

- The owner opens the app on a laptop and it looks deliberately designed for
  that width, not accidentally tolerable at it.
- Working weights and reps are readable at arm's length with the phone propped
  against a rack, under bright gym lighting, at reduced screen brightness.
- Changing the app's radius, shadow, or accent color is a one-file edit rather
  than a search-and-replace across components.
- A planning agent can implement this without inventing visual decisions:
  the palette roles, breakpoint behavior, and primitive list are all specified
  here.
- No screen retains a hardcoded color value.

---

## Scope Boundaries

- **Logging behavior is unchanged.** Ghost prefill and tap-to-confirm, the
  one-exercise-at-a-time session cursor, and replacing the Save button with
  per-set persistence are all deferred. They were the strongest ideas in
  ideation and are expected to follow, but mixing them in would make this a
  rewrite of `src/pages/Workout.tsx` rather than a redesign.
- **No desktop program editor.** Editing the 5-day split still happens through
  SQL migrations. This was explicitly cut — the owner's desktop use is review,
  not authoring.
- **No new screens or routes.** The four existing routes stay as they are.
- **No dark mode.** Light replaces dark rather than joining it. A
  `prefers-color-scheme` counterpart can be revisited once the semantic token
  tier exists, which is what would make it cheap.
- **No data-fetching or error-handling changes.** The ignored Supabase error
  channels are real, but they are a separate concern from the redesign.
- **No new charts or computed insights.** Existing charts get restyled and
  resized; the density canvas and auto-generated progress feed are deferred.

---

## Key Decisions

- **Athletic and bold over clean, warm, or soft.** Chosen for legibility under
  gym conditions, and because it keeps orange scarce and loud — the failure mode
  for blue-plus-orange is ambient saturation reading as a dated sports brand.
- **Desktop is a review surface, not a planning surface.** Determined by asking
  what the owner actually does on a laptop. This removed the largest and least
  certain piece of the original concept.
- **Primitives are harvested, not designed.** Every primitive must already be
  duplicated three or more times. This is a deliberate response to the standing
  instruction in `AGENTS.md` to prefer editing existing files over adding new
  ones — the rule is respected by extracting only proven duplication.
- **The Workout column stays narrow at all widths.** Desktop gets layout
  attention where review happens; the logger is not stretched to fill space.
- **Section color becomes an intensity encoding.** Six arbitrary hues would
  fight a two-color system and read as noise on a light ground.

---

## Dependencies / Assumptions

- The workout program revision (`supabase/migration_003_new_plan.sql`, currently
  uncommitted) should land before or alongside this work. If the revision
  changes the section vocabulary or introduces tracking types, R8 and R18 depend
  on knowing the final shape.
- Assumes the existing four-route information architecture is correct. Ideation
  raised merging History and Progress; that was not pursued.
- Assumes no test suite exists to protect this refactor — the repo has no test
  runner and no CI, so verification is by exercising the app.
- The `@theme` block is the only styling configuration; there is no separate
  Tailwind config file to reconcile.

---

## Outstanding Questions

### Resolve Before Planning

_None._

### Deferred to Planning

- [Affects R1, R2][Technical] Exact token names and ramp stops. The palette
  roles and contrast constraints are fixed here; the specific values are a
  planning-time decision.
- [Affects R8][Technical] Which sections map to which points on the intensity
  axis, pending the final program shape.
- [Affects R12, R14][Technical] Whether master-detail is implemented via routing
  or local selection state.
- [Affects R17][Technical] Where primitives live and how they are named.
- [Affects R9, R11][Needs research] Whether the current font stack supports the
  weights the bold treatment needs, or whether a typeface change is required.

---

## Next Steps

-> `/ce-plan` for structured implementation planning.
