---
date: 2026-07-19
topic: ui-redesign
focus: Complete UI redesign — responsive desktop + mobile, light palette (light blue + orange)
mode: repo-grounded
---

# Ideation: UI Redesign

48 raw candidates generated across 6 ideation frames, filtered to 7 survivors.
External grounding from a web research pass over fitness-app prior art.

## Grounding Context

### Codebase Context

React 19 + TS + Vite 8 + Tailwind 4 (CSS-first `@theme`), React Router 7,
Recharts, Supabase. Single user, PIN-gated. No test runner, no CI.

State of the UI at ideation time:

- **Zero responsive breakpoints anywhere.** No `sm:`/`md:`/`lg:` in the
  codebase. `Layout.tsx:32` pins content to `max-w-2xl mx-auto`, so a desktop
  monitor renders a phone-width strip in a dark void.
- **Dark theme** in a 13-token `@theme` block (`index.css:3-17`), plus a
  hardcoded `bg-[#0f0f1a]` at `Layout.tsx:16` that escapes the theme entirely.
- **No shared UI primitives.** The `bg-surface rounded-xl border` card shell is
  re-implemented in ~8 places; the numeric input class string is copy-pasted 4×
  inside `ExerciseCard.tsx` alone; the loading spinner is duplicated verbatim.
- **`ExerciseCard.tsx`** is 203 lines with three near-duplicate JSX branches for
  weighted / bodyweight / timed that differ only in which fields render. All
  cards open `expanded=true`, producing a very long scroll.
- **`Workout.tsx`** holds the whole session in local state and writes it via
  three sequential inserts at the end. Sets are seeded `weight_kg: 0, reps: 0`.
- **`Progress.tsx`** is empty until an exercise is picked from a dropdown, and
  hardcodes six dark hex values inside the Recharts tree (`:239-266`).
- **`History.tsx`** is a flat unbounded list; deletes use `window.confirm()`.

Unused affordances the schema already grants: `workout_sessions.status` only
ever gets `'completed'` (`'in_progress'` never used), `duration_mins` and
`notes` are never written, `exercises.muscle_group` appears nowhere in the UI,
and `session_exercises.skipped` / `original_exercise_id` are written on every
session but read nowhere.

### External Context

- **Strong and Hevy converge** on: sets pre-filled from last session, one tap to
  confirm; typing is the exception path, not the default.
- **POS terminals and warehouse scanners** independently reach the identical
  mechanic under matching constraints (hands occupied, interruptible task).
  Convergence across unrelated industries suggests a structural optimum.
- **Hevy's web app** is explicitly a planning/review surface — "program a
  routine on your desktop and track sets from your wrist." Desktop is a
  different task, not a shrunk-down logger.
- **Master-detail responsive spec:** single pane under ~600dp; at 600dp+ the
  list becomes a constrained card (~540dp max) rather than stretching; at
  840dp+ true two-pane.
- **Strava's rebrand** moved to a single saturated accent against neutral ground
  to read dynamic rather than static. A rainbow palette reads busy.
- **Category color convention:** red/orange = high intensity, cool blue/green =
  recovery.

### User Constraints

- Light palette, specifically **light blue + orange**.
- Must work on both desktop and mobile.
- The workout program itself is being revised in parallel
  (`supabase/migration_003_new_plan.sql`, currently uncommitted).

## Ranked Ideas

### 1. Light palette as a legibility contract, not a token swap

**Description:** Rebuild `index.css` around a light ground with a semantic token
tier (`--color-bg`, `--surface-raised`, `--text-muted`, `--border-strong`) over
a private raw ramp. Add the three scales that don't exist: radius, elevation,
type. Light needs real shadows because it cannot lean on surface-lightness steps
the way dark does.

Refined against the user's light-blue-and-orange constraint:

- Neither saturated color can carry text. `#F97316` is ~3.0:1 on white and
  `#7DD3FC` is ~1.6:1 — both fail. Working variants: `#EA580C` as a *fill* with
  white text (4.6:1), `#C2410C` when orange must be text (4.9:1), `#0369A1` for
  blue text and chart lines (5.9:1).
- **Role split:** orange = "now" and action (primary buttons, active-set cursor,
  confirm, streak) held under ~5% of pixels; light blue = structure and data
  (active nav, chart lines, section headers, density ramp).
- This lets the six-hue `SECTION_COLORS` rainbow collapse onto a single heat
  axis — explosive/finisher orange, strength ink, core neutral, mobility/stretch
  blue — so color encodes effort instead of acting as a legend.
- **Risk:** saturated blue + orange on white reads as 2010s sports brand.
  Mitigate by letting neutral ground carry surface area, desaturating blue
  toward slate for large regions, and using orange as fill only.

**Rationale:** A naive inversion breaks in three places the theme cannot reach —
the `/20`-opacity section tints built for a dark surface, the hardcoded Recharts
hex values, and the `bg-[#0f0f1a]` literal in `Layout.tsx`.

**Downsides:** Tempting to over-engineer a token system for a 5-page app. The
discipline is harvesting tokens from what already repeats.

**Confidence:** 95% · **Complexity:** Medium · **Status:** Explored

### 2. Two surfaces, one dataset: phone logs, desktop plans

**Description:** Branch the layouts rather than making existing pages
responsive. Under 600px, today's single pane. At 600px+, the column stays
constrained (~540px) and bottom nav becomes a left rail. At 840px+, true
two-pane master-detail, with desktop as the **program editor** — the thing the
app has no UI for at all.

**Rationale:** Zero breakpoints exist, so desktop is currently the worst of both
worlds. But "make the logger wider" is the wrong fix — nobody logs sets from a
laptop. This also closes a real gap: the 5-day split is currently edited by
hand-writing SQL migrations.

**Downsides:** Largest surface area. Two layouts to maintain, and a desktop
template editor is a new feature, not a redesign.

**Confidence:** 90% · **Complexity:** High · **Status:** Explored

### 3. Ghost prefill + tap-to-confirm

**Description:** Every set loads pre-filled with last session's numbers as
dimmed ghost values. Tap the row to commit as-is; typing overrides. A
`Last: 60×8, 60×8, 55×6` strip sits under each exercise header.

**Rationale:** The DB holds every past session and the logging screen asks for
none of it. On a ~7-exercise day this collapses ~25 keyboard entries to ~25
taps, converting logging from recall to recognition. Appeared independently in
all six ideation frames and matches the Strong/Hevy/POS convergence.

**Downsides:** Worthless on day one; value compounds with logging volume. Needs
a real cold-start design.

**Confidence:** 92% · **Complexity:** Medium · **Status:** Unexplored

### 4. Session cursor: one exercise at a time

**Description:** Replace the all-expanded scroll with a cursor — current
exercise fills the viewport, completed ones collapse to one-line receipts,
upcoming ones to a queue.

**Rationale:** The workout is inherently sequential; presenting it as a
simultaneous form fights that. Making position first-class state also unlocks
rest timers, auto-advance, and resume.

**Downsides:** Loses at-a-glance overview of the whole session.

**Confidence:** 80% · **Complexity:** Medium · **Status:** Unexplored

### 5. Component vocabulary harvested from existing duplication

**Description:** Extract the six shapes the code already repeats — `Surface`,
`Field`, `Button`, `Chip`, `Stack`, `AsyncBoundary` — roughly 150 lines. Collapse
`ExerciseCard`'s three tracking-type branches into one declarative field schema
(203 lines → ~90).

**Rationale:** Deduplication, not invention — every primitive is provably needed
by 3+ existing call sites, so there is no YAGNI risk. It is also what makes the
palette flip cheap: restyle six primitives, restyle the whole app.

**Downsides:** Pure refactor — no visible progress while it happens.

**Confidence:** 88% · **Complexity:** Medium · **Status:** Explored

### 6. Kill the Save button: the session is a live row

**Description:** Insert `workout_sessions` with `status: 'in_progress'` when a
template is picked; write each set as it is confirmed. The button becomes
"Finish" and flips status.

**Rationale:** This is a latent data-loss bug, not only a UX issue. Closing the
tab mid-workout destroys the session, and a partial failure leaves orphaned
session rows in History. The schema already anticipated this with an unused
`status` value.

**Downsides:** Changes the write model, touching everything. Needs an
abandoned-session cleanup story.

**Confidence:** 85% · **Complexity:** Medium · **Status:** Unexplored

### 7. Review surfaces: density canvas + auto progress feed

**Description:** History becomes a year density grid (tap a cell → session
detail). Progress opens as a ranked feed of computed cards — "Bench +7.5kg in 6
weeks," "skipped Pull-ups 3 of last 4 Day-2s" — with the dropdown demoted to
search.

**Rationale:** Progress currently asks the user to guess where progress happened
when the DB already knows. The `skipped` flag is written every session and read
nowhere.

**Downsides:** Most speculative of the seven. Insight generation is easy to get
wrong and can feel gimmicky.

**Confidence:** 70% · **Complexity:** High · **Status:** Unexplored

## Open Scope Question

Ideas 1, 2, 5, and 7 are UI redesign. Ideas 3, 4, and 6 are behavior changes —
they redesign what the app *does* during a workout, not how it looks. They are
also where the strongest cross-frame convergence landed. Whether the redesign
includes the logging model roughly doubles the scope and should be decided
deliberately.

Related: the workout program is being revised in parallel. If the program is
changing shape (sections, tracking types, exercise counts), that should settle
before the UI is rebuilt around it.

## Rejection Summary

| # | Idea | Reason Rejected |
|---|------|-----------------|
| 1 | Hands-free voice logging | Too expensive vs value; browser speech APIs unreliable in gym noise |
| 2 | Cricket scorebook glyph notation | Novel and charming, but a new notation the user must learn to read |
| 3 | SRS-graded sets (easy/right/hard) | RPE was explicitly removed in `c3b1aac`; reintroducing it fights a stated decision |
| 4 | Flowsheet grid (EHR time-series columns) | Strong idea but needs desktop width the mobile logger lacks — folded into #2 |
| 5 | Delete the Workout tab / template picker | Duplicates #4's cursor framing; nav simplification is a consequence, not an idea |
| 6 | Merge History + Progress into one zoom surface | Overlaps #7; the zoom metaphor is unproven |
| 7 | Template as a prior, not a script | Too vague to action now; revisit once the program revision settles |
| 8 | Offline / PWA local-first | Real, but #6 captures most of the value at a fraction of the cost |
| 9 | Five-years-in virtualized corpus | Premature — weeks of data, not 1,200 sessions |
| 10 | Stepper chips / rep dial | Folded into #3; prefilled values largely dissolve the keyboard problem |
| 11 | Deviation-as-novelty (chess repertoire) | Strongest cut. `original_exercise_id` is recorded and analyzed nowhere — but it is a feature, not a redesign |
| 12 | Exercise as primary object (per-exercise pages) | Overlaps #7's review surfaces without adding a distinct mechanism |
| 13 | Dashboard makes the decision for you | Small and good, but a detail inside #2's dashboard rework rather than a standalone idea |
| 14 | Punch-in transport bar (DAW) | The rest-timer half is real; the takes/comping metaphor does not survive contact with sets |
| 15 | Mise-en-place prep sheet | Interesting front-loading idea, but adds a whole pre-workout screen to solve what #3 solves inline |
| 16 | Working tree / commit (git) diff summary | Clever framing, but the diff view is ceremony for a single user who just lived the session |
| 17 | Day Zero first-run states | Genuinely needed, but a quality bar applied across every screen rather than an idea to rank |
