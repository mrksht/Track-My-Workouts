# Learnings

Things that cost time to discover and would cost the same again. Bugs whose
cause sat far from the symptom, Supabase behaviors that surprised us, patterns
in this codebase worth repeating or avoiding.

Search here before debugging in an unfamiliar area — that is the only reason the
directory earns its keep.

## Filename

`YYYY-MM-DD-short-slug.md` — `2026-07-19-swap-loses-original-exercise.md`.
Dated, because a learning is a claim about the codebase at a moment in time.

## Format

```markdown
---
title: Session insert leaves orphaned session_exercises on failure
type: bug               # bug | pattern | constraint | tooling
area: workout-logging   # workout-logging | schema | progress | auth | build
date: 2026-07-19
files:
  - src/pages/Workout.tsx
---

## Symptom

What was observed, concretely. Include the error text if there was one.

## Cause

The actual mechanism. Not "a race condition" — which two operations, in what
order, touching what state.

## Resolution

What fixed it, and where. Link to the code.

## How to recognize it again

The tell. What would make you suspect this cause next time, before you have
finished investigating.
```

## Keeping it honest

State what you verified and what you inferred. A learning that presents a guess
as a finding sends the next session down the same wrong path with more
confidence than you had.

If a learning is later contradicted, delete it. Wrong entries here are actively
harmful — they are consulted precisely when nobody has the context to doubt them.
