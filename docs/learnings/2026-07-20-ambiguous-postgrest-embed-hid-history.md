---
title: Ambiguous PostgREST embed silently emptied History
type: bug
area: schema
date: 2026-07-20
files:
  - src/pages/History.tsx
---

## Symptom

Expanding any session in History showed an empty panel — no exercises, no
sets. Every session, not just some. No console error, no failed request
visible in the network panel, no TypeScript complaint. The sessions
themselves listed fine; only the detail was blank.

The initial hypothesis was data loss — that `supabase/migration_003_new_plan.sql`
or a partial write in `Workout.tsx` had orphaned the sessions. That was wrong.
Querying the REST API directly showed 40 `session_exercises` and 131
`exercise_sets` present the whole time.

## Cause

`session_exercises` has **two** foreign keys to `exercises`:

```
exercise_id          -> exercises(id)
original_exercise_id -> exercises(id)   -- set when an exercise is swapped
```

The query wrote a bare embed, `exercise:exercises(name, category, muscle_group)`.
PostgREST cannot infer which relationship to traverse when two exist, so it
rejects the request with **HTTP 300 / PGRST201** rather than guessing.

The failure was invisible because the error channel was discarded:

```
const { data } = await supabase.from('session_exercises').select(...)
```

`data` came back `null`, the `if (data)` guard fell through, and the panel
rendered nothing. A 300 response is not an exception, so nothing surfaced.

A second bug was hiding underneath: the same select omitted `tracking_type`
while the render read `ex.exercise?.tracking_type || 'weighted'`. Every
exercise therefore took the fallback, so timed and bodyweight movements
displayed as weight × reps — a 13-minute treadmill walk read as `0kg × 0`.

## Resolution

Name the foreign key on both sides of the embed, and select the field the
render actually depends on:

```
exercise:exercises!session_exercises_exercise_id_fkey(name, category, muscle_group, tracking_type),
original_exercise:exercises!session_exercises_original_exercise_id_fkey(name)
```

The error is now logged rather than swallowed. Fixed in `3b588d5`.

## How to recognize it again

Any embed against a table with more than one FK to the same target needs the
`!constraint_name` hint. In this schema that is only `session_exercises` →
`exercises`; the `day_templates` and `template_exercises` embeds have a single
FK each and are unambiguous. Verified by hitting each one directly.

The broader tell: **a Supabase query destructured as `const { data } = await`
cannot fail loudly.** When a panel renders empty and nothing appears in the
console, suspect a discarded error before suspecting missing rows. Reproducing
the exact select with `curl` against `/rest/v1/` surfaces the real status code
and the `hint` field, which in this case named the fix outright.

Related: [[workout-save-is-not-atomic]] — the same discarded-error pattern
appears across the codebase, and `Workout.tsx` writes a session in three
sequential inserts with no transaction.
